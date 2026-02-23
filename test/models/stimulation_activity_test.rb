# frozen_string_literal: true

require "test_helper"

class StimulationActivityTest < ActiveSupport::TestCase
  test "validates presence of month" do
    activity = StimulationActivity.new(description: "Test activity")
    assert_not activity.valid?
    assert activity.errors[:month].any?
  end

  test "validates presence of description" do
    activity = StimulationActivity.new(month: 0)
    assert_not activity.valid?
    assert activity.errors[:description].any?
  end

  test "validates month range 0-36" do
    activity = StimulationActivity.new(month: -1, description: "Test")
    assert_not activity.valid?
    assert activity.errors[:month].any?

    activity = StimulationActivity.new(month: 37, description: "Test")
    assert_not activity.valid?
    assert activity.errors[:month].any?

    activity = StimulationActivity.new(month: 0, description: "Test")
    assert activity.valid?

    activity = StimulationActivity.new(month: 36, description: "Test")
    assert activity.valid?
  end

  test "for_month scope returns correct activities" do
    month_0_activities = StimulationActivity.for_month(0)
    assert month_0_activities.count >= 3
    assert month_0_activities.all? { |a| a.month == 0 }
  end

  test "for_month scope orders by position" do
    month_0_activities = StimulationActivity.for_month(0)
    positions = month_0_activities.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "ordered scope returns all activities ordered by month and position" do
    activities = StimulationActivity.ordered
    prev_month = -1
    prev_position = -1

    activities.each do |a|
      if a.month == prev_month
        assert a.position >= prev_position, "Position should be ordered within same month"
      else
        assert a.month >= prev_month, "Month should be ordered"
      end
      prev_month = a.month
      prev_position = a.position
    end
  end

  test "fixture data is loaded correctly" do
    activity = stimulation_activities(:month_0_activity_1)
    assert_equal 0, activity.month
    assert_equal 0, activity.position
    assert_not_nil activity.description
  end
end
