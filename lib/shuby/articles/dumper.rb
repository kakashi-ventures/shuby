# frozen_string_literal: true

require "json"

module Shuby
  module Articles
    # Walks docs/Articoli/<Categoria>/*.docx, parses each via DocxParser,
    # applies category mapping + specialist heuristic + reading-time, then
    # writes a flat JSON array to disk. The JSON file is committed to the
    # repo and read by Seeder in production deploys (where docs/Articoli/
    # is gitignored and unavailable).
    #
    # Source of truth: the .docx files. JSON is a derived artifact —
    # regenerate via `rake shuby:articles:dump` whenever .docx content
    # changes.
    class Dumper
      FOLDER_TO_CATEGORY = {
        "Attaccamento" => "Attaccamento",
        "Benessere Familiare" => "Benessere familiare",
        "Comunicazione e Linguaggio" => "Comunicazione e Linguaggio",
        "Infanzia e Schermi" => "Infanzia e Schermi",
        "Interesse, Relazione e Gioco" => "Interesse, Relazione e Gioco",
        "Neurosviluppo" => "Neurosviluppo",
        "Orecchie, Naso e Gola" => "Orecchie, Naso e Gola",
        "Pediatria" => "Pediatria",
        "Prevenzione" => "Prevenzione",
        "Regolazione e comportamento" => "Regolazione e comportamento",
        "Sessualità e dintorni" => "Sessualità e dintorni",
        "Sonno" => "Sonno",
        "Sviluppo motorio" => "Sviluppo motorio",
        "Sviluppo orale" => "Sviluppo orale"
      }.freeze

      SPECIALIST_FOLDERS = [
        "Neurosviluppo",
        "Orecchie, Naso e Gola",
        "Sessualità e dintorni",
        "Sviluppo orale"
      ].freeze

      SPECIALIST_TITLE_PATTERN = /apnee|ritardo|regressi|atipic|disturb/i

      WORDS_PER_MINUTE = 200

      def initialize(root:, output_path:, io: $stdout)
        @root = Pathname.new(root)
        @output_path = Pathname.new(output_path)
        @io = io
        @seen_slugs = Set.new
      end

      def run
        unless @root.directory?
          @io.puts "docs/Articoli/ not present at #{@root}, cannot dump."
          return false
        end

        files = Dir.glob(@root.join("*", "*.docx")).sort
        @io.puts "Parsing #{files.size} articles from #{@root}…"

        records = files.each_with_index.filter_map do |path, idx|
          build_record(Pathname.new(path), idx + 1)
        end

        @output_path.parent.mkpath
        @output_path.write(JSON.pretty_generate(records))

        @io.puts
        @io.puts "Wrote #{records.size} records → #{@output_path.relative_path_from(Rails.root)}"
        @io.puts "Size: #{(@output_path.size / 1024.0).round(1)} KB"
        @io.puts "Specialist: #{records.count { |r| r["specialist"] }} | Generic: #{records.count { |r| !r["specialist"] }}"
        true
      end

      private

      def build_record(path, position)
        folder = path.parent.basename.to_s
        category = FOLDER_TO_CATEGORY[folder]

        unless category
          @io.puts "  ⚠️  #{folder}/#{path.basename}: unknown folder, skipping"
          return nil
        end

        parsed = DocxParser.new(path).parse
        slug = build_slug(parsed)

        record = {
          "slug" => slug,
          "title" => parsed[:title],
          "description" => parsed[:description],
          "body_html" => parsed[:body_html],
          "category" => category,
          "min_age_months" => parsed[:age_min],
          "max_age_months" => parsed[:age_max],
          "duration_minutes" => reading_time_minutes(parsed[:word_count]),
          "specialist" => specialist?(folder, parsed),
          "position" => position
        }

        @io.puts format(
          "  ✓ %-30s %s (%d w, %s)",
          folder, parsed[:title].truncate(40), parsed[:word_count], age_label(parsed)
        )
        record
      end

      # Title-collision tiebreaker: identical titles across age bands
      # ("Lo sviluppo motorio del neonato" exists for 0-2, 2-3, 3-4, … mesi)
      # get distinct slugs by appending the age range.
      def build_slug(parsed)
        base = parsed[:title].parameterize
        slug = if @seen_slugs.include?(base)
          "#{base}-#{parsed[:age_min]}-#{parsed[:age_max]}-mesi"
        else
          base
        end
        @seen_slugs << base
        @seen_slugs << slug
        slug
      end

      def specialist?(folder, parsed)
        return true if SPECIALIST_FOLDERS.include?(folder)
        parsed[:title].match?(SPECIALIST_TITLE_PATTERN)
      end

      def reading_time_minutes(word_count)
        [(word_count.to_f / WORDS_PER_MINUTE).ceil, 1].max
      end

      def age_label(parsed)
        if parsed[:age_min] == 0 && parsed[:age_max] >= 36
          "0–36 mesi"
        elsif parsed[:age_min] == parsed[:age_max]
          "#{parsed[:age_min]} mesi"
        else
          "#{parsed[:age_min]}–#{parsed[:age_max]} mesi"
        end
      end
    end
  end
end
