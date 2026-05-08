# frozen_string_literal: true

module Shuby
  module Articles
    # Walks docs/Articoli/<Categoria>/*.docx and persists each as a published
    # ArchiveContent article. Idempotent on slug — re-running updates existing
    # records and refreshes their ActionText body in place.
    class Seeder
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

      # Whole-folder specialist topics — medical/clinical specialty content per
      # the subscription PDF: "Articoli specialistici (es. ritardo linguaggio,
      # regressioni, segnali atipici)".
      SPECIALIST_FOLDERS = [
        "Neurosviluppo",
        "Orecchie, Naso e Gola",
        "Sessualità e dintorni",
        "Sviluppo orale"
      ].freeze

      # Title-keyword tag — catches specialist articles inside otherwise generic
      # folders (e.g. "Apnee del Sonno" lives under Sonno but is clinical).
      SPECIALIST_TITLE_PATTERN = /apnee|ritardo|regressi|atipic|disturb/i

      # Italian average reading rate ~200 wpm. Used for duration_minutes so
      # cards show a "Tempo lettura" chip per PRD §3.7.2.
      WORDS_PER_MINUTE = 200

      def initialize(root:, io: $stdout)
        @root = Pathname.new(root)
        @io = io
        @stats = {created: 0, updated: 0, skipped: 0, failed: 0, by_category: Hash.new(0)}
        @seen_slugs = Set.new
      end

      def run
        unless @root.directory?
          @io.puts "docs/Articoli/ not present at #{@root}, skipping."
          return @stats
        end

        files = Dir.glob(@root.join("*", "*.docx")).sort
        @io.puts "Seeding #{files.size} articles from #{@root}…"

        files.each_with_index do |path, idx|
          ingest(Pathname.new(path), idx + 1)
        end

        print_summary
        @stats
      end

      private

      def ingest(path, position)
        folder = path.parent.basename.to_s
        category = FOLDER_TO_CATEGORY[folder]

        unless category
          @io.puts "  ⚠️  #{folder}/#{path.basename}: unknown folder, skipping"
          @stats[:skipped] += 1
          return
        end

        parsed = DocxParser.new(path).parse
        record = persist(parsed, category, folder, position)

        if record.previously_new_record?
          @stats[:created] += 1
          status = "created"
        else
          @stats[:updated] += 1
          status = "updated"
        end
        @stats[:by_category][category] += 1

        @io.puts format(
          "  ✓ %-30s %s — %s (%d words, %s)",
          folder, parsed[:title].truncate(40), status, parsed[:word_count], age_label(parsed)
        )
      rescue ParseError => e
        @stats[:failed] += 1
        @io.puts "  ✗ #{folder}/#{path.basename}: parse error — #{e.message}"
      rescue ActiveRecord::RecordInvalid => e
        @stats[:failed] += 1
        @io.puts "  ✗ #{folder}/#{path.basename}: invalid — #{e.message}"
      end

      def persist(parsed, category, folder, position)
        slug = build_slug(parsed, category)
        record = ArchiveContent.find_or_initialize_by(slug: slug)
        was_new = record.new_record?

        record.assign_attributes(
          title: parsed[:title],
          description: parsed[:description],
          content_type: :article,
          category: category,
          min_age_months: parsed[:age_min],
          max_age_months: parsed[:age_max],
          duration_minutes: reading_time_minutes(parsed[:word_count]),
          position: position,
          published: true,
          published_at: record.published_at || Time.current
        )
        # Heuristic specialist tag is set only on first import; admin overrides
        # via Madmin must survive subsequent re-runs.
        record.specialist = specialist_default(folder, parsed) if was_new
        record.body = parsed[:body_html]
        record.save!
        record
      end

      def reading_time_minutes(word_count)
        [(word_count.to_f / WORDS_PER_MINUTE).ceil, 1].max
      end

      def specialist_default(folder, parsed)
        return true if SPECIALIST_FOLDERS.include?(folder)
        parsed[:title].match?(SPECIALIST_TITLE_PATTERN)
      end

      # Several articles repeat the same title across age bands
      # ("Lo sviluppo motorio del neonato" exists for 0-2, 2-3, 3-4, … mesi).
      # We disambiguate by appending the age range when:
      #   1. a previous file in this run already claimed the same base slug, or
      #   2. an existing DB record with this slug belongs to a different
      #      category (cross-run safety net for stale records from a previous
      #      categorisation scheme).
      def build_slug(parsed, category)
        base = parsed[:title].parameterize
        slug = base

        if @seen_slugs.include?(base)
          slug = "#{base}-#{parsed[:age_min]}-#{parsed[:age_max]}-mesi"
        elsif (existing = ArchiveContent.find_by(slug: base)) && existing.category != category
          slug = "#{base}-#{parsed[:age_min]}-#{parsed[:age_max]}-mesi"
        end

        @seen_slugs << base
        @seen_slugs << slug
        slug
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

      def print_summary
        @io.puts
        @io.puts "Done. Created #{@stats[:created]} / Updated #{@stats[:updated]} / Skipped #{@stats[:skipped]} / Failed #{@stats[:failed]}"
        return if @stats[:by_category].empty?

        @io.puts "By category:"
        @stats[:by_category].sort.each do |cat, n|
          @io.puts format("  %-32s %d", cat, n)
        end
      end
    end
  end
end
