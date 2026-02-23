# frozen_string_literal: true

require "test_helper"

class WarningSignTest < ActiveSupport::TestCase
  test "validates presence of month" do
    warning_sign = WarningSign.new(description: "Test warning")
    assert_not warning_sign.valid?
    assert warning_sign.errors[:month].any?
  end

  test "validates presence of description" do
    warning_sign = WarningSign.new(month: 0)
    assert_not warning_sign.valid?
    assert warning_sign.errors[:description].any?
  end

  test "validates month range 0-36" do
    warning_sign = WarningSign.new(month: -1, description: "Test")
    assert_not warning_sign.valid?
    assert warning_sign.errors[:month].any?

    warning_sign = WarningSign.new(month: 37, description: "Test")
    assert_not warning_sign.valid?
    assert warning_sign.errors[:month].any?

    warning_sign = WarningSign.new(month: 0, description: "Test")
    assert warning_sign.valid?

    warning_sign = WarningSign.new(month: 36, description: "Test")
    assert warning_sign.valid?
  end

  test "for_month scope returns correct warnings" do
    month_0_warnings = WarningSign.for_month(0)
    assert month_0_warnings.count >= 2
    assert month_0_warnings.all? { |c| c.month == 0 }
  end

  test "for_month scope orders by position" do
    month_0_warnings = WarningSign.for_month(0)
    positions = month_0_warnings.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "ordered scope returns all warnings ordered by month and position" do
    warnings = WarningSign.ordered
    prev_month = -1
    prev_position = -1

    warnings.each do |w|
      if w.month == prev_month
        assert w.position >= prev_position, "Position should be ordered within same month"
      else
        assert w.month >= prev_month, "Month should be ordered"
      end
      prev_month = w.month
      prev_position = w.position
    end
  end

  test "valid record can be created" do
    warning_sign = WarningSign.new(month: 6, description: "Non si siede con supporto.", position: 0)
    assert warning_sign.valid?
    assert warning_sign.save
  end

  test "validates month is numeric" do
    warning_sign = WarningSign.new(month: "abc", description: "Test")
    assert_not warning_sign.valid?
    assert warning_sign.errors[:month].any?
  end

  test "for_month scope does not include other months" do
    results = WarningSign.for_month(0)
    assert results.none? { |c| c.month != 0 }
  end

  test "for_month scope returns empty for month with no warnings" do
    results = WarningSign.for_month(99)
    assert_empty results
  end

  test "position defaults to 0" do
    warning_sign = WarningSign.create!(month: 18, description: "Test warning without explicit position")
    assert_equal 0, warning_sign.position
  end

  test "fixture data is loaded correctly" do
    warning = warning_signs(:month_0_warning_1)
    assert_equal 0, warning.month
    assert_equal 0, warning.position
    assert_not_nil warning.description
  end
end
