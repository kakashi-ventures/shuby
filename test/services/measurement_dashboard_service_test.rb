# frozen_string_literal: true

require "test_helper"

class MeasurementDashboardServiceTest < ActiveSupport::TestCase
  test "returns up to MAX_BOXES measurement boxes" do
    boxes = MeasurementDashboardService.call(children(:sophia))
    assert boxes.size <= MeasurementDashboardService::MAX_BOXES
  end

  test "returns priority types in order" do
    boxes = MeasurementDashboardService.call(children(:sophia))
    expected_types = MeasurementDashboardService::PRIORITY_TYPES.first(MeasurementDashboardService::MAX_BOXES)
    assert_equal expected_types, boxes.map { |b| b.type }
  end

  test "state is :track for recent measurement" do
    boxes = MeasurementDashboardService.call(children(:sophia))
    weight_box = boxes.find { |b| b.type == "weight" }
    # sophia_weight_recent is 3 days old, sophia is ~2 months, threshold 14 days
    assert_equal :track, weight_box.state
  end

  test "state is :start_tracking when no measurement exists" do
    child = Child.create!(
      account: accounts(:company),
      name: "Newborn Test",
      birth_date: 1.week.ago.to_date
    )
    boxes = MeasurementDashboardService.call(child)
    assert boxes.all? { |b| b.state == :start_tracking }
  end

  test "state is :update for stale measurement" do
    boxes = MeasurementDashboardService.call(children(:luca))
    height_box = boxes.find { |b| b.type == "height" }
    # luca_height_stale is 70 days old, luca is ~18 months, threshold 60 days
    assert_equal :update, height_box.state
  end

  test "last_measurement is included in box" do
    boxes = MeasurementDashboardService.call(children(:sophia))
    weight_box = boxes.find { |b| b.type == "weight" }
    assert_not_nil weight_box.last_measurement
    assert_kind_of Measurement, weight_box.last_measurement
  end

  test "returns only priority types" do
    boxes = MeasurementDashboardService.call(children(:sophia))
    boxes.each do |box|
      assert_includes MeasurementDashboardService::PRIORITY_TYPES, box.type
    end
  end

  # picker_boxes — type-picker overlay (Figma 463:5785 / 463:5995 / 795:8492)
  test "picker_boxes returns one box per ALL_TYPES" do
    boxes = MeasurementDashboardService.picker_boxes(children(:sophia))
    assert_equal MeasurementDashboardService::ALL_TYPES, boxes.map(&:type)
  end

  test "picker_boxes includes feeding_weight (unlike call/MAX_BOXES)" do
    boxes = MeasurementDashboardService.picker_boxes(children(:sophia))
    assert_includes boxes.map(&:type), "feeding_weight"
  end

  test "picker_boxes derives state per type using same logic as call" do
    boxes = MeasurementDashboardService.picker_boxes(children(:luca))
    # luca_height_stale is 70 days old, luca is ~18 months, threshold 60 days.
    height_box = boxes.find { |b| b.type == "height" }
    assert_equal :update, height_box.state
  end

  test "picker_boxes returns :start_tracking for child with no measurements" do
    child = Child.create!(
      account: accounts(:company),
      name: "Picker Empty Test",
      birth_date: 1.week.ago.to_date
    )
    boxes = MeasurementDashboardService.picker_boxes(child)
    assert boxes.all? { |b| b.state == :start_tracking }
    assert_equal 4, boxes.size
  end
end
