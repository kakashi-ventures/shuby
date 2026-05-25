# frozen_string_literal: true

require "test_helper"

class MeasurementsHelperTest < ActionView::TestCase
  include MeasurementsHelper

  setup do
    @user = users(:one)
  end

  # === current_user stub for helper ===

  def current_user
    @user
  end

  # === measurement_display respects user preference ===

  test "measurement_display returns metric string when user pref is metric" do
    @user.measurement_unit = "metric"
    m = measurements(:sophia_weight_recent) # 4500g -> "4,5 kg" (DEC-022)
    assert_equal "4,5 kg", measurement_display(m)
  end

  test "measurement_display returns imperial string when user pref is imperial" do
    @user.measurement_unit = "imperial"
    m = measurements(:sophia_weight_recent) # 4500g -> 9.92 lb
    assert_equal "9,92 lb", measurement_display(m)
  end

  # === measurement_unit_label_for_type (empty-state helper) ===

  test "measurement_unit_label_for_type returns metric label by default" do
    @user.measurement_unit = "metric"
    assert_equal "kg", measurement_unit_label_for_type("weight")
    assert_equal "cm", measurement_unit_label_for_type("height")
    assert_equal "cm", measurement_unit_label_for_type("head_circumference")
    assert_equal "gr", measurement_unit_label_for_type("feeding_weight")
  end

  test "measurement_unit_label_for_type returns imperial label when user prefers imperial" do
    @user.measurement_unit = "imperial"
    assert_equal "lb", measurement_unit_label_for_type("weight")
    assert_equal "in", measurement_unit_label_for_type("height")
    assert_equal "in", measurement_unit_label_for_type("head_circumference")
    assert_equal "oz", measurement_unit_label_for_type("feeding_weight")
  end

  test "falls back to metric when current_user is nil" do
    @user = nil
    assert_equal "kg", measurement_unit_label_for_type("weight")
  end
end
