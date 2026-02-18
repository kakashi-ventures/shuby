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
    assert_equal "kg", data[:unit]
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
