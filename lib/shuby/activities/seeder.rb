# frozen_string_literal: true

require "json"

module Shuby
  module Activities
    # Reads the committed JSON fixture at db/seeds/archive_activities.json and
    # upserts ArchiveContent activity records. Idempotent on slug — re-running
    # updates title/materials/benefits/body/etc. and refreshes the ActionText
    # body in place.
    #
    # The fixture is hand-authored from a single docx in docs/content_4_21/ that
    # holds many activities; production deploys never touch the .docx files
    # (they are gitignored), so the committed JSON is the source of truth.
    class Seeder
      def initialize(json_path:, io: $stdout)
        @json_path = Pathname.new(json_path)
        @io = io
        @stats = {created: 0, updated: 0, skipped: 0, failed: 0, by_age_band: Hash.new(0)}
      end

      def run
        unless @json_path.file?
          @io.puts "#{@json_path.relative_path_from(Rails.root)} not present, skipping."
          return @stats
        end

        records = JSON.parse(@json_path.read)
        @io.puts "Seeding #{records.size} activities from #{@json_path.relative_path_from(Rails.root)}…"

        records.each { |attrs| ingest(attrs) }

        print_summary
        @stats
      end

      private

      def ingest(attrs)
        record = ArchiveContent.find_or_initialize_by(slug: attrs.fetch("slug"))

        record.assign_attributes(
          title: attrs.fetch("title"),
          content_type: :activity,
          materials: attrs["materials"],
          benefits: attrs.fetch("benefits", []),
          min_age_months: attrs.fetch("min_age_months"),
          max_age_months: attrs.fetch("max_age_months"),
          duration_minutes: attrs["duration_minutes"],
          position: attrs["position"],
          published: true,
          published_at: record.published_at || Time.current
        )
        # Specialist flag is set only on first import; admin overrides via
        # Madmin must survive subsequent re-runs.
        record.specialist = attrs.fetch("specialist", false) if record.new_record?
        record.body = attrs["body_html"]
        record.save!

        if record.previously_new_record?
          @stats[:created] += 1
        else
          @stats[:updated] += 1
        end
        @stats[:by_age_band][age_band(attrs)] += 1
      rescue ActiveRecord::RecordInvalid => e
        @stats[:failed] += 1
        @io.puts "  ✗ #{attrs["slug"]}: invalid — #{e.message}"
      end

      def age_band(attrs)
        "#{attrs.fetch("min_age_months")}–#{attrs.fetch("max_age_months")} mesi"
      end

      def print_summary
        @io.puts
        @io.puts "Done. Created #{@stats[:created]} / Updated #{@stats[:updated]} / Skipped #{@stats[:skipped]} / Failed #{@stats[:failed]}"
        return if @stats[:by_age_band].empty?

        @io.puts "By age band:"
        @stats[:by_age_band].sort.each do |band, n|
          @io.puts format("  %-16s %d", band, n)
        end
      end
    end
  end
end
