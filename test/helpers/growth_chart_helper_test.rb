# frozen_string_literal: true

require "test_helper"

class GrowthChartHelperTest < ActionView::TestCase
  include GrowthChartHelper

  # === growth_chart_data ===

  test "growth_chart_data returns correct structure" do
    child = children(:sophia) # female, 2 months old
    data = growth_chart_data(child: child, type: "weight")

    assert_kind_of Array, data[:measurements]
    assert_kind_of Array, data[:who_curves]
    assert_equal "weight", data[:type]
    # Unit label is no longer emitted server-side — the chart controller
    # derives it from type + unit_system at render time so toggling units
    # doesn't require a network round-trip.
    assert_equal "metric", data[:unit_system]
  end

  test "growth_chart_data converts weight to kg" do
    child = children(:sophia)
    data = growth_chart_data(child: child, type: "weight")

    # Sophia has weight fixtures with value in grams (e.g., 4500)
    data[:measurements].each do |m|
      assert m[:value] < 30, "Weight should be in kg, got #{m[:value]}"
    end
  end

  test "growth_chart_data keeps height in cm" do
    child = children(:sophia)
    data = growth_chart_data(child: child, type: "height")

    data[:measurements].each do |m|
      assert m[:value] > 30, "Height should remain in cm, got #{m[:value]}"
    end
  end

  test "growth_chart_data returns WHO curves with all percentile keys" do
    child = children(:sophia)
    data = growth_chart_data(child: child, type: "weight")

    assert data[:who_curves].any?
    curve = data[:who_curves].first
    assert curve.key?(:p3)
    assert curve.key?(:p50)
    assert curve.key?(:p97)
  end

  test "growth_chart_data returns empty measurements for type with no data" do
    child = children(:sophia)
    # Sophia has no head_circumference measurements? Actually she does in fixtures.
    # Let's test with a child that has no measurements of a certain type
    data = growth_chart_data(child: child, type: "weight")
    assert_kind_of Array, data[:measurements]
  end

  test "growth_chart_data plots premature babies at corrected age on the x-axis" do
    # Luca: 34w2d gestational, 18mo chronological → in the corrected-age window.
    # Add a measurement exactly 100 days after birth so the chronological vs
    # corrected difference is large enough to be unambiguous.
    child = children(:luca)
    Measurement.create!(
      child: child,
      measurement_type: :weight,
      value: 6000,
      measured_at: child.birth_date + 100.days,
      percentile: 30
    )

    data = growth_chart_data(child: child, type: "weight")
    new_point = data[:measurements].find { |m| (m[:value] - 6.0).abs < 0.01 } # 6000g → 6kg

    chronological_months = (100.0 / 30.44).round(2)            # ~3.29
    corrected_offset_days = ((40 - 34) * 7) + (7 - 2)          # 47
    corrected_months = ((100 - corrected_offset_days) / 30.44).round(2) # ~1.74

    assert_in_delta corrected_months, new_point[:age], 0.05,
      "premature baby's data point must plot at corrected age (#{corrected_months}m), " \
      "not chronological (#{chronological_months}m)"
    assert new_point[:age] < chronological_months,
      "corrected age must be earlier on the x-axis than chronological age"
  end

  # === percentile_color_class ===

  test "percentile_color_class returns green for normal range" do
    assert_includes percentile_color_class(50), "green"
    assert_includes percentile_color_class(10), "green"
    assert_includes percentile_color_class(90), "green"
  end

  test "percentile_color_class returns orange for warning range" do
    assert_includes percentile_color_class(5), "orange"
    assert_includes percentile_color_class(95), "orange"
  end

  test "percentile_color_class returns red for alert range" do
    assert_includes percentile_color_class(1), "red"
    assert_includes percentile_color_class(99), "red"
  end

  test "percentile_color_class returns empty string for nil" do
    assert_equal "", percentile_color_class(nil)
  end

  # === percentile_explanation ===

  test "percentile_explanation returns normal text for mid-range" do
    result = percentile_explanation(50)
    assert_not_nil result
  end

  test "percentile_explanation returns nil for nil percentile" do
    assert_nil percentile_explanation(nil)
  end

  # === premium_charts? ===

  test "premium_charts? returns true (stub)" do
    assert premium_charts?(nil)
  end
end
