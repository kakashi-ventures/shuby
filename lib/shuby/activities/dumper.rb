# frozen_string_literal: true

require "cgi"
require "json"

module Shuby
  module Activities
    # Walks docs/Activities/*.docx, parses each via the shared
    # Shuby::Articles::DocxParser, lifts out the optional labeled fields
    # (Materiali / Durata / Benefici) and the "Fascia d'età" age footer, and
    # writes a flat JSON array to db/seeds/archive_activities.json.
    #
    # The JSON is committed and read by Seeder in production deploys, where
    # docs/Activities/ is gitignored and unavailable. Source of truth: the .docx
    # files — regenerate via `rake shuby:activities:dump` whenever they change.
    #
    # Authoring convention (parse-if-present) — optional labeled lines in the docx:
    #   Materiali: scatola, cuscino            → materials (string)
    #   Durata: 10 minuti                      → duration_minutes (first integer)
    #   Benefici: Favorisce X; Stimola Y       → benefits (split on ";")
    #   Benefici:                              → benefits, OR a bare header line
    #     • Favorisce X                          followed by a bulleted list
    #     • Stimola Y
    # Absent labels leave the field empty. Parsed lines are stripped from the body.
    class Dumper
      MATERIALS_LABEL = /\A\s*Material[ei]\s*:\s*(.+)/i
      DURATION_LABEL = /\A\s*Durata\s*:\s*(.+)/i
      # Inline benefits: "Benefici: a; b; c".
      BENEFITS_INLINE = /\A\s*Benefici\s*:\s*(.+)/i
      # Header benefits: a bare "Benefici" / "Benefici:" line whose items live in
      # a bulleted list on the following block.
      BENEFITS_HEADER = /\A\s*Benefici\s*:?\s*\z/i
      # Age footer — parsed upstream into min/max by DocxParser, dropped from the
      # body here. Tolerant of straight/curly/entity apostrophes (entity decoded
      # before matching).
      FOOTER_LABEL = /\A\s*Fascia\s+d.{0,3}et[àa]/i

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

        enriched = records.count { |r| r["materials"] || r["duration_minutes"] || r["benefits"].any? }
        @io.puts
        @io.puts "Wrote #{records.size} records → #{@output_path.relative_path_from(Rails.root)}"
        @io.puts "Size: #{(@output_path.size / 1024.0).round(1)} KB"
        @io.puts "Enriched: #{enriched}/#{records.size} files carry optional fields (materials/durata/benefici)"
        true
      end

      private

      def build_record(path, position)
        parsed = Shuby::Articles::DocxParser.new(path).parse
        fields = extract_fields(parsed[:body_html])

        record = {
          "slug" => build_slug(parsed),
          "title" => parsed[:title],
          "body_html" => fields[:body],
          "materials" => fields[:materials],
          "benefits" => fields[:benefits],
          "min_age_months" => parsed[:age_min],
          "max_age_months" => parsed[:age_max],
          "duration_minutes" => fields[:duration_minutes],
          "specialist" => false,
          "position" => position
        }

        @io.puts format("  ✓ %-44s %d–%d mesi%s", parsed[:title].truncate(44), parsed[:age_min], parsed[:age_max], field_tags(record))
        record
      rescue Shuby::Articles::ParseError => e
        @io.puts "  ✗ #{path.basename}: #{e.message}"
        nil
      end

      # Single pass over the body's blocks (the parser emits one block per line —
      # <p>, <ul>/<ol>, <hN>). Pulls out the optional Materiali/Durata/Benefici
      # fields and the age footer; keeps the rest as the clean prose body.
      # Benefits accept two forms: an inline "Benefici: a; b" line, or a bare
      # "Benefici:" line/heading immediately followed by a bulleted list.
      def extract_fields(body_html)
        materials = nil
        duration = nil
        benefits = []
        kept = []
        expect_benefits_list = false

        body_html.to_s.split("\n").each do |block|
          next if block.strip.empty?

          if list_block?(block)
            if expect_benefits_list
              benefits = list_items(block)
            else
              kept << block
            end
            expect_benefits_list = false
            next
          end

          expect_benefits_list = false
          text = plain_text(block)

          if (m = text.match(MATERIALS_LABEL))
            materials = m[1].strip
          elsif (m = text.match(DURATION_LABEL))
            duration = m[1][/\d+/]&.to_i
          elsif (m = text.match(BENEFITS_INLINE))
            benefits = split_inline(m[1])
          elsif text.match?(BENEFITS_HEADER)
            expect_benefits_list = true
          elsif text.match?(FOOTER_LABEL)
            next
          else
            kept << block
          end
        end

        {body: kept.join("\n"), materials: materials, duration_minutes: duration, benefits: benefits}
      end

      def list_block?(block)
        block.start_with?("<ul", "<ol")
      end

      def list_items(block)
        block.scan(%r{<li>(.*?)</li>}m).map { |li| plain_text(li[0]) }.reject(&:empty?)
      end

      def split_inline(value)
        value.split(";").map(&:strip).reject(&:empty?)
      end

      # Tag-stripped, entity-decoded text of one block — the basis for label
      # matching and the stored plain-text values. The kept body retains the
      # original HTML, not this plain form.
      def plain_text(fragment)
        CGI.unescapeHTML(fragment.gsub(/<[^>]+>/, "")).strip
      end

      # Compact " [mat,dur,ben(2)]" suffix on the dump line, so the content team
      # can confirm at a glance which optional fields were recognized. Empty when
      # the file carries none.
      def field_tags(record)
        tags = []
        tags << "mat" if record["materials"]
        tags << "dur" if record["duration_minutes"]
        tags << "ben(#{record["benefits"].size})" if record["benefits"].any?
        tags.empty? ? "" : " [#{tags.join(",")}]"
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
