# frozen_string_literal: true

require "test_helper"

class TimelineStageContentTest < ActiveSupport::TestCase
  test "for_band returns matching row by pill key" do
    band = Timeline::AgeBands.find_by_key("sett_1")
    assert_equal "sett_1", TimelineStageContent.for_band(band).pill_key
  end

  test "for_band looks up monthly pill" do
    band = Timeline::AgeBands.find_by_key("mese_12")
    assert_equal "mese_12", TimelineStageContent.for_band(band).pill_key
  end

  test "for_band returns nil when band has no content row" do
    band = Timeline::AgeBands.find_by_key("mese_4")
    assert_nil TimelineStageContent.for_band(band)
  end

  test "for_band returns nil when band is nil" do
    assert_nil TimelineStageContent.for_band(nil)
  end

  test "weekly? and monthly? predicates" do
    assert_predicate timeline_stage_contents(:sett_1), :weekly?
    refute_predicate timeline_stage_contents(:sett_1), :monthly?
    assert_predicate timeline_stage_contents(:mese_3), :monthly?
    refute_predicate timeline_stage_contents(:mese_3), :weekly?
  end

  test "suggestions populated on weekly rows" do
    assert_predicate timeline_stage_contents(:sett_1).suggestions, :present?
    assert_predicate timeline_stage_contents(:sett_8).suggestions, :present?
  end

  test "suggestions nil on monthly rows" do
    assert_nil timeline_stage_contents(:mese_3).suggestions
    assert_nil timeline_stage_contents(:mese_36).suggestions
  end

  test "pill_key required" do
    record = TimelineStageContent.new(description: "x")
    refute record.valid?
    assert record.errors[:pill_key].any?
  end

  test "pill_key must match sett_N or mese_N format" do
    record = TimelineStageContent.new(pill_key: "yearly_1", description: "x")
    refute record.valid?
    assert record.errors[:pill_key].any?
  end

  test "pill_key must be unique" do
    duplicate = TimelineStageContent.new(
      pill_key: timeline_stage_contents(:sett_1).pill_key,
      description: "x"
    )
    refute duplicate.valid?
    assert duplicate.errors[:pill_key].any?
  end

  test "description required" do
    record = TimelineStageContent.new(pill_key: "sett_3")
    refute record.valid?
    assert record.errors[:description].any?
  end
end
