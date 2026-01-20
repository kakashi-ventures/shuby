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

  test "validates uniqueness of slug after generation" do
    existing = development_areas(:comunicazione)
    # Create another area with the same name, which will generate the same slug
    area = DevelopmentArea.new(name: existing.name, color: "#000000", position: 10)
    assert_not area.valid?
    # Both name and slug should be duplicates
    assert area.errors[:name].any? || area.errors[:slug].any?, "Expected name or slug uniqueness error"
  end

  test "validates uniqueness of name" do
    existing = development_areas(:comunicazione)
    area = DevelopmentArea.new(name: existing.name, slug: "unique-slug", color: "#000000")
    assert_not area.valid?
    assert area.errors[:name].any?
  end

  test "validates uniqueness of slug" do
    existing = development_areas(:comunicazione)
    area = DevelopmentArea.new(name: "Unique Name", slug: existing.slug, color: "#000000")
    assert_not area.valid?
    assert area.errors[:slug].any?
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
    assert_equal 1, questionnaire.max_age_months
  end

  test "questionnaire_for_age returns nil for age without questionnaire" do
    area = development_areas(:comunicazione)
    # Only months 0-3 questionnaires exist in fixtures
    questionnaire = area.questionnaire_for_age(100)
    assert_nil questionnaire
  end

  test "has many age_band_questionnaires" do
    area = development_areas(:comunicazione)
    assert_respond_to area, :age_band_questionnaires
    assert area.age_band_questionnaires.count > 0
  end
end
