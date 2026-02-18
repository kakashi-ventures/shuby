# frozen_string_literal: true

require "test_helper"

class ReportDataAggregatorTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
  end

  # === Hash structure ===

  test "returns hash with all expected top-level keys" do
    result = ReportDataAggregator.call(@child)
    expected_keys = %i[header general_info measurements development questionnaires pediatrician_questions notes]
    assert_equal expected_keys.sort, result.keys.sort
  end

  # === Header ===

  test "header contains child identity data" do
    result = ReportDataAggregator.call(@child)
    header = result[:header]

    assert_equal @child.display_name, header[:child_name]
    assert_equal @child.birth_date, header[:birth_date]
    assert_equal @child.sex, header[:sex]
    assert_kind_of Time, header[:generated_at]
    assert_not_nil header[:current_age]
  end

  test "header includes corrected age for premature child" do
    luca = children(:luca) # premature
    result = ReportDataAggregator.call(luca)
    header = result[:header]

    assert header[:premature]
    assert_not_nil header[:corrected_age]
  end

  test "header has nil corrected_age for full-term child" do
    result = ReportDataAggregator.call(@child)
    assert_nil result[:header][:corrected_age]
    assert_not result[:header][:premature]
  end

  # === General info ===

  test "general_info handles missing health profile" do
    # Sophia has no health_profile fixture
    result = ReportDataAggregator.call(@child)
    assert_kind_of Hash, result[:general_info]
  end

  test "general_info handles missing family profile" do
    result = ReportDataAggregator.call(@child)
    assert_kind_of Hash, result[:general_info]
  end

  # === Measurements ===

  test "measurements contains recent latest and alerts arrays" do
    result = ReportDataAggregator.call(@child)
    measurements = result[:measurements]

    assert_kind_of Array, measurements[:recent]
    assert_kind_of Array, measurements[:latest]
    assert_kind_of Array, measurements[:alerts]
  end

  test "measurements excludes feeding_weight from recent" do
    result = ReportDataAggregator.call(@child)
    types = result[:measurements][:recent].map { |m| m[:type] }
    assert_not_includes types, "feeding_weight"
  end

  test "measurements excludes feeding_weight from latest" do
    result = ReportDataAggregator.call(@child)
    types = result[:measurements][:latest].map { |m| m[:type] }
    assert_not_includes types, "feeding_weight"
  end

  test "measurement rows have expected keys" do
    result = ReportDataAggregator.call(@child)
    row = result[:measurements][:recent].first
    return if row.nil? # skip if no measurements

    assert_includes row.keys, :type
    assert_includes row.keys, :display_value
    assert_includes row.keys, :percentile
    assert_includes row.keys, :measured_at
  end

  test "alerts include measurements with percentile below 3" do
    # Create a measurement with very low percentile
    m = @child.measurements.create!(
      measurement_type: :weight,
      value: 2500,
      measured_at: 1.day.ago,
      percentile: 2
    )

    result = ReportDataAggregator.call(@child)
    alert_types = result[:measurements][:alerts].map { |a| a[:type] }
    assert_includes alert_types, "weight"
  ensure
    m&.destroy
  end

  test "alerts include measurements with percentile above 97" do
    m = @child.measurements.create!(
      measurement_type: :height,
      value: 65,
      measured_at: 1.day.ago,
      percentile: 98
    )

    result = ReportDataAggregator.call(@child)
    alert_types = result[:measurements][:alerts].map { |a| a[:type] }
    assert_includes alert_types, "height"
  ensure
    m&.destroy
  end

  # === Development ===

  test "development returns array with entry per development area" do
    result = ReportDataAggregator.call(@child)
    assert_equal DevelopmentArea.count, result[:development].size
  end

  test "development entries have expected keys" do
    result = ReportDataAggregator.call(@child)
    entry = result[:development].first

    assert_includes entry.keys, :area_name
    assert_includes entry.keys, :completed
    assert_includes entry.keys, :percentage
    assert_includes entry.keys, :yes_rate
    assert_includes entry.keys, :needs_attention
  end

  # === Questionnaires ===

  test "questionnaires lists only completed sessions" do
    result = ReportDataAggregator.call(@child)
    # Sophia has 2 completed sessions in fixtures
    assert result[:questionnaires].all? { |q| q[:completed_at].present? }
  end

  test "questionnaire entries have expected keys" do
    result = ReportDataAggregator.call(@child)
    return if result[:questionnaires].empty?

    entry = result[:questionnaires].first
    expected_keys = %i[area_name age_band completed_at yes_count no_count unknown_count needs_attention]
    expected_keys.each do |key|
      assert_includes entry.keys, key, "Missing key: #{key}"
    end
  end

  # === Pediatrician questions ===

  test "pediatrician_questions returns ordered question texts" do
    result = ReportDataAggregator.call(@child)
    questions = result[:pediatrician_questions]

    assert_kind_of Array, questions
    assert_equal 2, questions.size
    assert_kind_of String, questions.first
  end

  # === Notes ===

  test "notes returns child notes" do
    result = ReportDataAggregator.call(@child)
    assert_nil result[:notes] unless @child.notes
    assert_equal @child.notes, result[:notes] if @child.notes
  end

  # === Empty data handling ===

  test "handles child with no measurements" do
    child = children(:luca)
    child.measurements.destroy_all

    result = ReportDataAggregator.call(child)
    assert_empty result[:measurements][:recent]
    assert_empty result[:measurements][:latest]
    assert_empty result[:measurements][:alerts]
  end

  test "handles child with no pediatrician questions" do
    child = children(:marco_inactive)
    result = ReportDataAggregator.call(child)
    assert_empty result[:pediatrician_questions]
  end
end
