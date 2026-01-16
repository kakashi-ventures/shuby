# frozen_string_literal: true

require "test_helper"

class CampanelloAllarmeTest < ActiveSupport::TestCase
  test "validates presence of month" do
    campanello = CampanelloAllarme.new(description: "Test warning")
    assert_not campanello.valid?
    assert_includes campanello.errors[:month], "can't be blank"
  end

  test "validates presence of description" do
    campanello = CampanelloAllarme.new(month: 0)
    assert_not campanello.valid?
    assert_includes campanello.errors[:description], "can't be blank"
  end

  test "validates month range 0-36" do
    campanello = CampanelloAllarme.new(month: -1, description: "Test")
    assert_not campanello.valid?
    assert campanello.errors[:month].any?

    campanello = CampanelloAllarme.new(month: 37, description: "Test")
    assert_not campanello.valid?
    assert campanello.errors[:month].any?

    campanello = CampanelloAllarme.new(month: 0, description: "Test")
    assert campanello.valid?

    campanello = CampanelloAllarme.new(month: 36, description: "Test")
    assert campanello.valid?
  end

  test "for_month scope returns correct warnings" do
    month_0_warnings = CampanelloAllarme.for_month(0)
    assert month_0_warnings.count >= 2
    assert month_0_warnings.all? { |c| c.month == 0 }
  end

  test "for_month scope orders by position" do
    month_0_warnings = CampanelloAllarme.for_month(0)
    positions = month_0_warnings.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "ordered scope returns all warnings ordered by month and position" do
    warnings = CampanelloAllarme.ordered
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

  test "fixture data is loaded correctly" do
    warning = campanelli_allarme(:month_0_warning_1)
    assert_equal 0, warning.month
    assert_equal 0, warning.position
    assert_not_nil warning.description
  end
end
