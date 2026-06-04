# frozen_string_literal: true

require "test_helper"

class StageReportDataAggregatorTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    # sophia is ~2 months → "sett_1" is a past (reached) band. Its mese_0 DB
    # questionnaires carry the seeded sessions + responses.
    @band = Timeline::AgeBands.find_by_key("sett_1")
  end

  test "builds the band header" do
    data = StageReportDataAggregator.call(@child, @band)

    assert_equal @child.display_name, data[:header][:child_name]
    assert_equal "Sett. 1", data[:header][:band_label]
    assert_kind_of Time, data[:header][:generated_at]
  end

  test "completed area exposes its questions and answers" do
    data = StageReportDataAggregator.call(@child, @band)
    area = area_named(data, development_areas(:comunicazione).name)

    assert_equal :completed, area[:status]
    assert_equal 3, area[:questions].size
    assert_includes area[:questions].map { |q| q[:prompt] }, "Reagisce alla voce della mamma?"
    assert_includes area[:questions].map { |q| q[:answer] }, "si"
    # completed_session answers: si, si, incerto
    assert_equal 2, area[:yes_count]
    assert_equal 1, area[:unknown_count]
    assert_not_nil area[:completed_at]
  end

  test "area without a completed session is marked not started with blank answers" do
    data = StageReportDataAggregator.call(@child, @band)
    area = area_named(data, development_areas(:motricita).name)

    assert_equal :not_started, area[:status]
    assert area[:questions].any?, "questions should still be listed"
    assert area[:questions].all? { |q| q[:answer].nil? }, "answers should be blank"
  end

  test "area without a questionnaire for the band is marked not available" do
    data = StageReportDataAggregator.call(@child, @band)
    area = area_named(data, development_areas(:consolidamento).name)

    assert_equal :not_available, area[:status]
    assert_empty area[:questions]
  end

  test "returns one entry per development area" do
    data = StageReportDataAggregator.call(@child, @band)
    assert_equal DevelopmentArea.count, data[:areas].size
  end

  private

  def area_named(data, name)
    data[:areas].find { |a| a[:area_name] == name }
  end
end
