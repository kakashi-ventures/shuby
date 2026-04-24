# frozen_string_literal: true

require "test_helper"

class User::MeasurementUnitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "defaults to metric when preference is blank" do
    @user.preferences = {}
    assert_equal "metric", @user.measurement_unit
    assert @user.metric_units?
    assert_not @user.imperial_units?
  end

  test "returns stored preference when set to imperial" do
    @user.update!(measurement_unit: "imperial")
    assert_equal "imperial", @user.reload.measurement_unit
    assert @user.imperial_units?
    assert_not @user.metric_units?
  end

  test "rejects values outside UNITS constant" do
    @user.measurement_unit = "cubits"
    assert_not @user.valid?
    assert @user.errors[:measurement_unit].any?
  end

  test "accepts nil (treated as default metric)" do
    @user.measurement_unit = nil
    assert @user.valid?
    assert_equal "metric", @user.measurement_unit
  end

  test "UNITS constant contains expected values" do
    assert_equal %w[metric imperial], User::MeasurementUnit::UNITS
  end
end
