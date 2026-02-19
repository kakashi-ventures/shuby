# frozen_string_literal: true

require "test_helper"

class WhoGrowthStandardTest < ActiveSupport::TestCase
  # === LMS Lookup ===

  test "lms_for returns correct values for male weight at birth" do
    lms = WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 0)
    assert_equal 0.3487, lms[:l]
    assert_equal 3.3464, lms[:m]
    assert_equal 0.14602, lms[:s]
  end

  test "lms_for returns correct values for female height at 12 months" do
    lms = WhoGrowthStandard.lms_for(sex: :female, type: :height, age_months: 12)
    assert_equal 1.0, lms[:l]
    assert_in_delta 74.0049, lms[:m], 0.01
  end

  test "lms_for returns correct values for male head_circumference at 6 months" do
    lms = WhoGrowthStandard.lms_for(sex: :male, type: :head_circumference, age_months: 6)
    assert_equal 1.0, lms[:l]
    assert_in_delta 43.3393, lms[:m], 0.01
  end

  test "lms_for clamps age to 0-36 range" do
    lms = WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 40)
    assert_not_nil lms # returns month 36 data
    assert_equal WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 36), lms
  end

  test "lms_for handles negative age by clamping to 0" do
    lms = WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: -1)
    assert_not_nil lms
    assert_equal WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 0), lms
  end

  test "lms_for floors fractional age" do
    lms = WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 6.7)
    assert_equal WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: 6), lms
  end

  test "lms_for returns nil for unsupported sex" do
    assert_nil WhoGrowthStandard.lms_for(sex: :unspecified, type: :weight, age_months: 6)
    assert_nil WhoGrowthStandard.lms_for(sex: :intersex, type: :weight, age_months: 6)
  end

  test "lms_for returns nil for feeding_weight type" do
    assert_nil WhoGrowthStandard.lms_for(sex: :male, type: :feeding_weight, age_months: 6)
  end

  # === Percentile Curves ===

  test "percentile_curves returns 37 entries for full 0-36 range" do
    curves = WhoGrowthStandard.percentile_curves(sex: :male, type: :weight)
    assert_equal 37, curves.size
    assert_equal 0, curves.first[:month]
    assert_equal 36, curves.last[:month]
  end

  test "percentile_curves entries contain all expected percentile keys" do
    curves = WhoGrowthStandard.percentile_curves(sex: :female, type: :height)
    entry = curves.first
    assert entry.key?(:month)
    assert entry.key?(:p3)
    assert entry.key?(:p10)
    assert entry.key?(:p25)
    assert entry.key?(:p50)
    assert entry.key?(:p75)
    assert entry.key?(:p90)
    assert entry.key?(:p97)
  end

  test "percentile_curves values are in ascending order" do
    curves = WhoGrowthStandard.percentile_curves(sex: :male, type: :weight)
    curves.each do |entry|
      assert entry[:p3] < entry[:p10]
      assert entry[:p10] < entry[:p25]
      assert entry[:p25] < entry[:p50]
      assert entry[:p50] < entry[:p75]
      assert entry[:p75] < entry[:p90]
      assert entry[:p90] < entry[:p97]
    end
  end

  test "percentile_curves P50 matches M value for male weight at birth" do
    curves = WhoGrowthStandard.percentile_curves(sex: :male, type: :weight)
    # P50 (z=0) should equal the median (M)
    assert_in_delta 3.3464, curves.first[:p50], 0.01
  end

  test "percentile_curves respects from_month and to_month" do
    curves = WhoGrowthStandard.percentile_curves(sex: :male, type: :weight, from_month: 6, to_month: 12)
    assert_equal 7, curves.size
    assert_equal 6, curves.first[:month]
    assert_equal 12, curves.last[:month]
  end

  test "percentile_curves returns empty array for unsupported sex" do
    assert_empty WhoGrowthStandard.percentile_curves(sex: :unspecified, type: :weight)
  end

  # === Data Integrity ===

  test "WHO data covers all 37 months for each sex and type combination" do
    %i[male female].each do |sex|
      %i[weight height head_circumference].each do |type|
        (0..36).each do |month|
          lms = WhoGrowthStandard.lms_for(sex: sex, type: type, age_months: month)
          assert_not_nil lms, "Missing LMS for #{sex} #{type} at month #{month}"
          assert lms[:m] > 0, "M value must be positive for #{sex} #{type} at month #{month}"
          assert lms[:s] > 0, "S value must be positive for #{sex} #{type} at month #{month}"
        end
      end
    end
  end

  test "median weight increases with age for boys" do
    prev_m = 0
    (0..36).each do |month|
      lms = WhoGrowthStandard.lms_for(sex: :male, type: :weight, age_months: month)
      assert lms[:m] > prev_m, "Weight median should increase at month #{month}"
      prev_m = lms[:m]
    end
  end

  test "median height increases with age for girls" do
    prev_m = 0
    (0..36).each do |month|
      lms = WhoGrowthStandard.lms_for(sex: :female, type: :height, age_months: month)
      assert lms[:m] > prev_m, "Height median should increase at month #{month}"
      prev_m = lms[:m]
    end
  end
end
