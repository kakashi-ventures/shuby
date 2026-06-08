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

      # Floor (not exact) so adding/removing a source docx + re-dumping doesn't
      # break the suite, while a truncated/empty dump still fails loudly.
      test "fixture holds the docs/Activities batch with unique slugs" do
        assert_operator SLUGS.size, :>=, 90, "expected the full docs/Activities activity batch"
        assert_equal SLUGS.uniq, SLUGS, "fixture slugs must be unique"
      end

      test "seeds every fixture entry as published, free, category-less activity content" do
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

      test "maps title, body and age band; leaves docx-absent fields empty" do
        seed!

        activity = ArchiveContent.find_by(slug: "acchiapparella")
        assert_equal "Acchiapparella", activity.title
        assert activity.body.present?, "ActionText body should be set"
        assert_not_includes activity.body.to_plain_text, "Fascia", "age footer must be stripped from body"
        assert_equal 8, activity.min_age_months
        assert_equal 12, activity.max_age_months
        assert_nil activity.materials, "source docx carry no materials"
        assert_empty activity.benefits, "source docx carry no benefits"
        assert_nil activity.duration_minutes, "source docx carry no duration"
      end

      test "is idempotent on slug — re-running updates in place without duplicating" do
        seed!
        count = ArchiveContent.activities.count

        seed!
        assert_equal count, ArchiveContent.activities.count, "re-run must not duplicate records"
      end

      test "prunes activity rows whose slug is absent from the fixture" do
        seed!
        stray = ArchiveContent.create!(
          slug: "attivita-fantasma", title: "Attività fantasma", content_type: :activity,
          min_age_months: 0, max_age_months: 6, published: true
        )

        seed!
        assert_nil ArchiveContent.find_by(id: stray.id), "stray activity should be pruned"
      end

      test "pruning is scoped to activities — articles and tips survive" do
        article = ArchiveContent.create!(
          slug: "articolo-da-preservare", title: "Articolo da preservare", content_type: :article,
          category: "Sonno", min_age_months: 0, max_age_months: 36, published: true
        )
        tip = ArchiveContent.create!(
          slug: "consiglio-da-preservare", title: "Consiglio da preservare", content_type: :tip,
          category: "Giochi", min_age_months: 0, max_age_months: 6, published: true
        )

        seed!

        assert ArchiveContent.find_by(id: article.id), "articles must survive activity pruning"
        assert ArchiveContent.find_by(id: tip.id), "tips must survive activity pruning"
      end
    end
  end
end
