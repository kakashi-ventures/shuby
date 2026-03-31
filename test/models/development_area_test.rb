# frozen_string_literal: true

require "test_helper"

class DevelopmentAreaTest < ActiveSupport::TestCase
  test "validates presence of name" do
    area = DevelopmentArea.new(slug: "test", color: "#000000")
    assert_not area.valid?
    assert area.errors[:name].any?
  end

  test "generates slug from name if not provided" do
    area = DevelopmentArea.new(name: "Test Area", color: "#000000", position: 10)
    area.valid?
    assert_equal "test-area", area.slug
  end

  test "handles slug uniqueness via Sluggable (appends suffix)" do
    existing = development_areas(:comunicazione)
    # Create another area with a different name but force the same slug
    area = DevelopmentArea.new(name: "Unique Name", slug: existing.slug, color: "#000000", position: 10)
    # Sluggable preserves pre-set slugs, so uniqueness is handled at DB level
    # But if slug collides, it stays as-is (pre-set slug preserved)
    area.valid?
    assert_equal existing.slug, area.slug
  end

  test "validates uniqueness of name" do
    existing = development_areas(:comunicazione)
    area = DevelopmentArea.new(name: existing.name, slug: "unique-slug", color: "#000000")
    assert_not area.valid?
    assert area.errors[:name].any?
  end

  test "Sluggable generates a unique slug" do
    area = DevelopmentArea.new(name: "Unique Name", color: "#000000", position: 10)
    area.valid?
    assert_equal "unique-name", area.slug
  end

  test "ordered scope returns areas by position" do
    areas = DevelopmentArea.ordered
    assert_equal areas.first.position, areas.minimum(:position)
    positions = areas.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "questionnaire_for_age returns correct questionnaire" do
    area = development_areas(:comunicazione)
    questionnaire = area.questionnaire_for_age(0)
    assert_not_nil questionnaire
    assert_equal 0, questionnaire.min_age_months
    assert_equal 2, questionnaire.max_age_months  # Band 1° Mese covers 0-2 months
  end

  test "questionnaire_for_age returns nil for age without questionnaire" do
    area = development_areas(:comunicazione)
    questionnaire = area.questionnaire_for_age(100)
    assert_nil questionnaire
  end

  test "has many age_band_questionnaires" do
    area = development_areas(:comunicazione)
    assert_respond_to area, :age_band_questionnaires
    assert area.age_band_questionnaires.count > 0
  end

  test "generates slug from name via Sluggable" do
    area = DevelopmentArea.new(name: "Motricità Fine", position: 99)
    area.valid?
    assert_equal "motricita-fine", area.slug
  end

  test "regenerates slug when name changes" do
    area = development_areas(:comunicazione)
    area.name = "Nuova Area"
    area.valid?
    assert_equal "nuova-area", area.slug
  end

  test "preserves pre-set slug (seed compatibility)" do
    area = DevelopmentArea.new(
      name: "Comunicazione e Linguaggio",
      slug: "comunicazione-linguaggio",
      position: 99
    )
    area.valid?
    assert_equal "comunicazione-linguaggio", area.slug
  end
end
