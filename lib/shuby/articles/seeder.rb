# frozen_string_literal: true

require "json"

module Shuby
  module Articles
    # Reads the committed JSON fixture at db/seeds/archive_articles.json and
    # upserts ArchiveContent records. Idempotent on slug — re-running updates
    # title/description/body/etc. and refreshes the ActionText body in place.
    #
    # The JSON fixture is generated locally by Shuby::Articles::Dumper from
    # docs/Articoli/*.docx; production deploys never touch the .docx files.
    class Seeder
      def initialize(json_path:, io: $stdout)
        @json_path = Pathname.new(json_path)
        @io = io
        @stats = {created: 0, updated: 0, skipped: 0, failed: 0, by_category: Hash.new(0)}
      end

      def run
        unless @json_path.file?
          @io.puts "#{@json_path.relative_path_from(Rails.root)} not present, skipping."
          return @stats
        end

        records = JSON.parse(@json_path.read)
        @io.puts "Seeding #{records.size} articles from #{@json_path.relative_path_from(Rails.root)}…"

        records.each { |attrs| ingest(attrs) }

        print_summary
        @stats
      end

      private

      def ingest(attrs)
        record = ArchiveContent.find_or_initialize_by(slug: attrs.fetch("slug"))

        record.assign_attributes(
          title: attrs.fetch("title"),
          description: attrs["description"],
          content_type: :article,
          category: attrs.fetch("category"),
          min_age_months: attrs.fetch("min_age_months"),
          max_age_months: attrs.fetch("max_age_months"),
          duration_minutes: attrs["duration_minutes"],
          position: attrs["position"],
          published: true,
          published_at: record.published_at || Time.current
        )
        # Heuristic specialist tag is set only on first import; admin overrides
        # via Madmin must survive subsequent re-runs.
        record.specialist = attrs.fetch("specialist") if record.new_record?
        record.body = attrs["body_html"]
        record.save!

        if record.previously_new_record?
          @stats[:created] += 1
        else
          @stats[:updated] += 1
        end
        @stats[:by_category][attrs.fetch("category")] += 1
      rescue ActiveRecord::RecordInvalid => e
        @stats[:failed] += 1
        @io.puts "  ✗ #{attrs["slug"]}: invalid — #{e.message}"
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
