# frozen_string_literal: true

require "json"

module Shuby
  module Activities
    # Walks docs/Activities/*.docx, parses each via the shared
    # Shuby::Articles::DocxParser, strips the trailing "Fascia d'età" footer
    # (activities surface the age band as a badge, not as body text), and writes
    # a flat JSON array to db/seeds/archive_activities.json.
    #
    # The JSON is committed and read by Seeder in production deploys, where
    # docs/Activities/ is gitignored and unavailable. Source of truth: the .docx
    # files — regenerate via `rake shuby:activities:dump` whenever they change.
    #
    # The source documents carry only title + prose + age range — no category,
    # materials, benefits, or duration — so those fields are emitted empty for
    # later editorial enrichment via Madmin.
    class Dumper
      # Matches the "Fascia d'età: 8-12 mesi" footer paragraph the parser leaves
      # in body_html — usually wrapped in <strong>, using a straight ('), curly
      # (’) or HTML-entity (&#39;) apostrophe. The tempered (?!</p>) keeps the
      # match inside the final paragraph (so leading inline tags are tolerated);
      # the \z anchor strips only the trailing line.
      FOOTER_PARAGRAPH = %r{<p>(?:(?!</p>).)*Fascia\s+d.{0,6}et[àa].*?</p>\s*\z}i

      def initialize(root:, output_path:, io: $stdout)
        @root = Pathname.new(root)
        @output_path = Pathname.new(output_path)
        @io = io
        @seen_slugs = Set.new
      end

      def run
        unless @root.directory?
          @io.puts "#{@root} not present, cannot dump."
          return false
        end

        files = Dir.glob(@root.join("*.docx")).sort
        @io.puts "Parsing #{files.size} activities from #{@root}…"

        records = files.each_with_index.filter_map do |path, idx|
          build_record(Pathname.new(path), idx + 1)
        end

        @output_path.parent.mkpath
        @output_path.write(JSON.pretty_generate(records))

        @io.puts
        @io.puts "Wrote #{records.size} records → #{@output_path.relative_path_from(Rails.root)}"
        @io.puts "Size: #{(@output_path.size / 1024.0).round(1)} KB"
        true
      end

      private

      def build_record(path, position)
        parsed = Shuby::Articles::DocxParser.new(path).parse
        record = {
          "slug" => build_slug(parsed),
          "title" => parsed[:title],
          "body_html" => strip_footer(parsed[:body_html]),
          "materials" => nil,
          "benefits" => [],
          "min_age_months" => parsed[:age_min],
          "max_age_months" => parsed[:age_max],
          "duration_minutes" => nil,
          "specialist" => false,
          "position" => position
        }

        @io.puts format("  ✓ %-44s %d–%d mesi", parsed[:title].truncate(44), parsed[:age_min], parsed[:age_max])
        record
      rescue Shuby::Articles::ParseError => e
        @io.puts "  ✗ #{path.basename}: #{e.message}"
        nil
      end

      def strip_footer(body_html)
        body_html.to_s.sub(FOOTER_PARAGRAPH, "").strip
      end

      # Mirrors Articles::Dumper#build_slug: identical titles get distinct slugs
      # by appending the age range. Activity titles look unique, but the guard is
      # cheap insurance against a future duplicate.
      def build_slug(parsed)
        base = parsed[:title].parameterize
        slug = @seen_slugs.include?(base) ? "#{base}-#{parsed[:age_min]}-#{parsed[:age_max]}-mesi" : base
        @seen_slugs << base << slug
        slug
      end
    end
  end
end
