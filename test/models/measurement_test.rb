# frozen_string_literal: true

require "test_helper"

class MeasurementTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid measurement" do
    m = Measurement.new(
      child: children(:sophia),
      measurement_type: :weight,
      value: 4000,
      measured_at: 1.day.ago
    )
    assert m.valid?
  end

  test "requires measurement_type" do
    m = Measurement.new(child: children(:sophia), value: 4000, measured_at: Time.current)
    assert_not m.valid?
    assert m.errors[:measurement_type].any?
  end

  test "requires value" do
    m = Measurement.new(child: children(:sophia), measurement_type: :weight, measured_at: Time.current)
    assert_not m.valid?
    assert m.errors[:value].any?
  end

  test "requires value to be greater than 0" do
    m = Measurement.new(child: children(:sophia), measurement_type: :weight, value: -1, measured_at: Time.current)
    assert_not m.valid?
    assert m.errors[:value].any?
  end

  test "requires measured_at" do
    m = Measurement.new(child: children(:sophia), measurement_type: :weight, value: 4000)
    assert_not m.valid?
    assert m.errors[:measured_at].any?
  end

  test "measured_at cannot be in future" do
    m = Measurement.new(
      child: children(:sophia),
      measurement_type: :weight,
      value: 4000,
      measured_at: 1.hour.from_now
    )
    assert_not m.valid?
    assert m.errors[:measured_at].present?
  end

  test "percentile must be between 0 and 100" do
    m = Measurement.new(
      child: children(:sophia),
      measurement_type: :weight,
      value: 4000,
      measured_at: 1.day.ago,
      percentile: 101
    )
    assert_not m.valid?
    assert m.errors[:percentile].any?
  end

  test "percentile allows nil" do
    m = Measurement.new(
      child: children(:sophia),
      measurement_type: :weight,
      value: 4000,
      measured_at: 1.day.ago,
      percentile: nil
    )
    assert m.valid?
  end

  # === Value range validations ===

  test "weight must be between 500 and 25000" do
    too_low = Measurement.new(child: children(:sophia), measurement_type: :weight, value: 100, measured_at: 1.day.ago)
    too_high = Measurement.new(child: children(:sophia), measurement_type: :weight, value: 26_000, measured_at: 1.day.ago)
    assert_not too_low.valid?
    assert_not too_high.valid?
    assert too_low.errors[:value].present?
    assert too_high.errors[:value].present?
  end

  test "height must be between 30 and 120" do
    too_low = Measurement.new(child: children(:sophia), measurement_type: :height, value: 10, measured_at: 1.day.ago)
    too_high = Measurement.new(child: children(:sophia), measurement_type: :height, value: 130, measured_at: 1.day.ago)
    assert_not too_low.valid?
    assert_not too_high.valid?
  end

  test "head_circumference must be between 20 and 60" do
    too_low = Measurement.new(child: children(:sophia), measurement_type: :head_circumference, value: 10, measured_at: 1.day.ago)
    too_high = Measurement.new(child: children(:sophia), measurement_type: :head_circumference, value: 70, measured_at: 1.day.ago)
    assert_not too_low.valid?
    assert_not too_high.valid?
  end

  test "feeding_weight must be between 1 and 500" do
    too_low = Measurement.new(child: children(:sophia), measurement_type: :feeding_weight, value: 0.5, measured_at: 1.day.ago)
    too_high = Measurement.new(child: children(:sophia), measurement_type: :feeding_weight, value: 600, measured_at: 1.day.ago)
    assert_not too_low.valid?
    assert_not too_high.valid?
  end

  # === Enums ===

  test "enum measurement_type values" do
    expected = {"weight" => 0, "height" => 1, "head_circumference" => 2, "feeding_weight" => 3}
    assert_equal expected, Measurement.measurement_types
  end

  # === Scopes ===

  test "ordered scope returns measurements by measured_at desc" do
    measurements = children(:sophia).measurements.by_type(:weight).ordered
    assert measurements.first.measured_at >= measurements.last.measured_at
  end

  test "by_type scope filters by measurement type" do
    weights = children(:sophia).measurements.by_type(:weight)
    assert weights.all?(&:weight?)
  end

  test "latest_per_type returns one measurement per type" do
    results = children(:sophia).measurements.latest_per_type
    types = results.map(&:measurement_type)
    assert_equal types.uniq.size, types.size
  end

  # === Display helpers ===

  test "display_value for weight shows grams" do
    m = measurements(:sophia_weight_recent)
    assert_equal "4500 gr", m.display_value
  end

  test "display_value for height shows cm" do
    m = measurements(:sophia_height)
    assert_match(/cm/, m.display_value)
  end

  test "display_value for feeding_weight shows plus sign" do
    m = measurements(:sophia_feeding)
    assert_match(/^\+/, m.display_value)
  end

  test "unit returns correct unit string" do
    assert_equal "gr", measurements(:sophia_weight_recent).unit
    assert_equal "cm", measurements(:sophia_height).unit
    assert_equal "cm", measurements(:sophia_head).unit
    assert_equal "gr", measurements(:sophia_feeding).unit
  end

  # === Staleness ===

  test "STALENESS_THRESHOLDS constant is defined and frozen" do
    assert_kind_of Hash, Measurement::STALENESS_THRESHOLDS
    assert Measurement::STALENESS_THRESHOLDS.frozen?
  end

  test "staleness_days_for returns correct thresholds" do
    assert_equal 14, Measurement.staleness_days_for(2)
    assert_equal 30, Measurement.staleness_days_for(8)
    assert_equal 60, Measurement.staleness_days_for(18)
    assert_equal 90, Measurement.staleness_days_for(30)
    assert_equal 90, Measurement.staleness_days_for(40)
  end

  test "staleness_days_for handles boundary ages correctly" do
    assert_equal 14, Measurement.staleness_days_for(3)   # upper bound of 0..3
    assert_equal 30, Measurement.staleness_days_for(4)   # lower bound of 4..12
    assert_equal 30, Measurement.staleness_days_for(12)  # upper bound of 4..12
    assert_equal 60, Measurement.staleness_days_for(13)  # lower bound of 13..24
    assert_equal 60, Measurement.staleness_days_for(24)  # upper bound of 13..24
    assert_equal 90, Measurement.staleness_days_for(25)  # lower bound of 25..36
  end

  test "stale? returns true when measurement is older than threshold" do
    m = measurements(:sophia_weight_stale)
    # Sophia is ~2 months old, threshold is 14 days, measurement is 20 days old
    assert m.stale?(2)
  end

  test "stale? returns false when measurement is within threshold" do
    m = measurements(:sophia_weight_recent)
    # Sophia is ~2 months old, threshold is 14 days, measurement is 3 days old
    assert_not m.stale?(2)
  end

  test "stale? returns true when measured_at is nil" do
    m = Measurement.new(measurement_type: :weight, value: 4000)
    assert m.stale?(2)
  end
end
