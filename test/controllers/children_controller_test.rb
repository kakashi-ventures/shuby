# frozen_string_literal: true

require "test_helper"

class ChildrenControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @child = children(:emma)
    sign_in @user
    switch_account(@account)
  end

  test "show on info tab renders the last_updated caption when measurements exist" do
    @child.measurements.create!(measurement_type: :weight, value: 7500, measured_at: 1.day.ago)
    get child_path(@child)
    assert_response :success
    assert_includes response.body, "ULTIMO AGGIORNAMENTO"
  end

  test "show on info tab hides the last_updated caption when child has no measurements" do
    @child.measurements.destroy_all

    get child_path(@child)
    assert_response :success
    refute_includes response.body, "ULTIMO AGGIORNAMENTO"
  end

  test "update accepts birth_height_cm via nested health profile attributes" do
    patch child_path(@child), params: {
      child: {
        name: @child.name,
        birth_date: @child.birth_date,
        sex: @child.sex,
        health_profile_attributes: {birth_height_cm: 50.5}
      }
    }

    assert_redirected_to child_path(@child)
    assert_equal 50.5, @child.reload.health_profile.birth_height_cm
  end
end
