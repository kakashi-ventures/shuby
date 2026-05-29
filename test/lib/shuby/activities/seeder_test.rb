# frozen_string_literal: true

require "test_helper"
require "stringio"

module Shuby
  module Activities
    class SeederTest < ActiveSupport::TestCase
      JSON_PATH = Rails.root.join("db/seeds/archive_activities.json")
      SLUGS = JSON.parse(File.read(JSON_PATH)).map { |attrs| attrs.fetch("slug") }.freeze

      def seed!
        Shuby::Activities::Seeder.new(json_path: JSON_PATH, io: StringIO.new).run
      end

      test "fixture holds 16 activities with unique slugs" do
        assert_equal 16, SLUGS.size
        assert_equal SLUGS.uniq, SLUGS, "fixture slugs must be unique"
      end

      test "seeds every fixture entry as published, free activity content" do
        seed!

        SLUGS.each do |slug|
          activity = ArchiveContent.find_by(slug: slug)
          assert activity, "expected activity #{slug} to be seeded"
          assert activity.content_type_activity?, "#{slug} should be content_type activity"
          assert activity.published?, "#{slug} should be published"
          assert_not activity.specialist?, "#{slug} should be free (non-specialist)"
          assert_nil activity.category, "#{slug} should have no category"
        end
      end

      test "maps materials, benefits, body and age band onto the record" do
        seed!

        activity = ArchiveContent.find_by(slug: "dove-si-nasconde-gioco-sulle-frasi-locative")
        assert_equal "Dove si nasconde? — Gioco sulle frasi locative", activity.title
        assert activity.materials.present?, "materials should be set"
        assert activity.benefits.any?, "benefits should be populated for the Benefici section"
        assert activity.body.present?, "ActionText body should be set"
        assert_includes activity.body.to_plain_text, "Come si gioca"
        assert_equal 24, activity.min_age_months
        assert_equal 36, activity.max_age_months
        assert_nil activity.duration_minutes, "source has no duration; tag is omitted"
      end

      test "is idempotent on slug — re-running updates in place" do
        seed!
        seeded = ArchiveContent.where(slug: SLUGS).count
        assert_equal 16, seeded

        seed!
        assert_equal seeded, ArchiveContent.where(slug: SLUGS).count, "re-run must not duplicate records"
      end
    end
  end
end
