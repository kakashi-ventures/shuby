# frozen_string_literal: true

require "test_helper"

class Timeline::AgeBandsTest < ActiveSupport::TestCase
  test "ALL contains weeks and months" do
    assert_equal 8, Timeline::AgeBands::WEEKS.size
    assert_equal 34, Timeline::AgeBands::MONTHS.size # 3 through 36
    assert_equal 42, Timeline::AgeBands::ALL.size
  end

  test "weeks have correct label type" do
    Timeline::AgeBands::WEEKS.each do |band|
      assert_equal "Sett.", band[:label_type]
    end
  end

  test "months have correct label type" do
    Timeline::AgeBands::MONTHS.each do |band|
      assert_equal "Mese", band[:label_type]
    end
  end

  test "find_by_key returns correct band" do
    band = Timeline::AgeBands.find_by_key("sett_3")
    assert_not_nil band
    assert_equal 3, band[:label_number]
    assert_equal "Sett.", band[:label_type]
  end

  test "find_by_key returns nil for unknown key" do
    assert_nil Timeline::AgeBands.find_by_key("unknown")
  end

  test "for_child_age returns week pill for age 0" do
    band = Timeline::AgeBands.for_child_age(0)
    assert_equal "Sett.", band[:label_type]
  end

  test "for_child_age returns month pill for age 6" do
    band = Timeline::AgeBands.for_child_age(6)
    assert_equal "mese_6", band[:key]
  end

  test "for_child_age clamps to 36" do
    band = Timeline::AgeBands.for_child_age(40)
    assert_equal "mese_36", band[:key]
  end

  test "week bands map to age_months 0 or 1" do
    Timeline::AgeBands::WEEKS.each do |band|
      assert_includes [0, 1], band[:age_months],
        "Week #{band[:label_number]} should map to month 0 or 1"
    end
  end

  test "month bands age_months equals label_number" do
    Timeline::AgeBands::MONTHS.each do |band|
      assert_equal band[:label_number], band[:age_months]
    end
  end

  test "all bands have unique keys" do
    keys = Timeline::AgeBands::ALL.map { |b| b[:key] }
    assert_equal keys.uniq.size, keys.size
  end
end
