# frozen_string_literal: true

require "test_helper"

class PercentileCalculatorTest < ActiveSupport::TestCase
  # === Known Reference Values ===

  test "male weight at birth near P50 returns approximately 50" do
    # WHO male weight M at birth = 3.3464 kg = 3346 grams
    child = children(:luca) # male
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 3346, # grams, close to median 3.3464 kg
      measured_at: child.birth_date.to_datetime
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_in_delta 50, percentile, 5
  end

  test "female height at 2 months near P50 returns approximately 50" do
    # Sophia is ~2 months old, female
    # WHO female height M at 2 months = 57.0796 cm
    child = children(:sophia) # female
    m = Measurement.new(
      child: child,
      measurement_type: :height,
      value: 57.0,
      measured_at: 1.day.ago
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_in_delta 50, percentile, 5
  end

  test "very heavy baby returns high percentile" do
    child = children(:sophia) # female, 2 months old
    # WHO female weight M at 2 months = 5.1315 kg, so 6.5 kg is well above median
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 6500, # grams
      measured_at: child.birth_date.to_datetime + 2.months
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert percentile > 90, "Expected >90th percentile, got #{percentile}"
  end

  test "very light baby returns low percentile" do
    child = children(:sophia) # female, 2 months old
    # WHO female weight M at 2 months = 5.1315 kg, so 3.9 kg is well below
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 3900, # grams
      measured_at: child.birth_date.to_datetime + 2.months
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert percentile < 10, "Expected <10th percentile, got #{percentile}"
  end

  # === Unsupported Inputs ===

  test "returns nil for feeding_weight type" do
    child = children(:sophia)
    m = Measurement.new(
      child: child,
      measurement_type: :feeding_weight,
      value: 80,
      measured_at: 1.day.ago
    )
    assert_nil PercentileCalculator.call(measurement: m, child: child)
  end

  test "returns nil when child sex is unspecified" do
    child = children(:sophia)
    child.sex = :unspecified
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 4500,
      measured_at: 1.day.ago
    )
    assert_nil PercentileCalculator.call(measurement: m, child: child)
  end

  test "returns nil when child has no birth_date" do
    child = children(:sophia)
    child.birth_date = nil
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 4500,
      measured_at: 1.day.ago
    )
    assert_nil PercentileCalculator.call(measurement: m, child: child)
  end

  test "returns nil when measurement has no measured_at" do
    child = children(:sophia)
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 4500,
      measured_at: nil
    )
    assert_nil PercentileCalculator.call(measurement: m, child: child)
  end

  # === Corrected Age for Premature Babies ===

  test "uses corrected age for premature baby under 24 months" do
    child = children(:luca) # male, premature (34 weeks + 2 days), 18 months old
    # Luca is 6 weeks early (40-34=6 weeks). Corrected age ≈ 18 - 1.5 ≈ 16.5 months

    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 10000, # 10 kg
      measured_at: 1.day.ago
    )

    # Calculate with corrected age (should use ~16-17 month LMS, not 18 month)
    percentile_premature = PercentileCalculator.call(measurement: m, child: child)

    # Compare with same child without prematurity (would use 18 month LMS)
    child_fullterm = child.dup
    child_fullterm.gestational_weeks = 40
    percentile_fullterm = PercentileCalculator.call(measurement: m, child: child_fullterm)

    # Premature child should get a higher percentile (corrected age is younger,
    # so the same weight appears relatively higher on the curve)
    assert percentile_premature > percentile_fullterm,
      "Premature percentile (#{percentile_premature}) should exceed full-term (#{percentile_fullterm})"
  end

  # === Result Bounds ===

  test "percentile is clamped between 0 and 100" do
    child = children(:sophia)
    # Extremely low weight for a 2-month-old girl
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 2000, # very low
      measured_at: child.birth_date.to_datetime + 2.months
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_includes 0..100, percentile
  end

  # === Edge Cases ===

  test "works at birth (month 0)" do
    child = children(:sophia)
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 3200,
      measured_at: child.birth_date.to_datetime
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_not_nil percentile
    assert_includes 0..100, percentile
  end

  test "works at 36 months" do
    child = children(:marco_inactive) # 3 years old, male
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 14300,
      measured_at: child.birth_date.to_datetime + 36.months
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_not_nil percentile
    assert_includes 0..100, percentile
  end

  test "returns integer value" do
    child = children(:sophia)
    m = Measurement.new(
      child: child,
      measurement_type: :weight,
      value: 4500,
      measured_at: 1.day.ago
    )
    percentile = PercentileCalculator.call(measurement: m, child: child)
    assert_kind_of Integer, percentile
  end
end
