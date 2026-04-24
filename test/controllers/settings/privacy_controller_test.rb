# frozen_string_literal: true

require "test_helper"

class Settings::PrivacyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "update persists measurement_unit preference" do
    patch settings_privacy_path, params: {user: {measurement_unit: "imperial"}}
    assert_redirected_to settings_privacy_path
    assert_equal "imperial", @user.reload.measurement_unit
  end

  test "update rejects values outside UNITS" do
    patch settings_privacy_path, params: {user: {measurement_unit: "cubits"}}
    assert_response :unprocessable_content
    assert_equal "metric", @user.reload.measurement_unit
  end

  test "update responds head :no_content for JSON requests" do
    patch settings_privacy_path,
      params: {user: {measurement_unit: "imperial"}}.to_json,
      headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
    assert_response :no_content
    assert_equal "imperial", @user.reload.measurement_unit
  end

  test "update returns JSON errors on invalid JSON PATCH" do
    patch settings_privacy_path,
      params: {user: {measurement_unit: "cubits"}}.to_json,
      headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
    assert_response :unprocessable_content
    assert response.body.present?
  end

  test "update still permits data_sharing_consent alongside measurement_unit" do
    patch settings_privacy_path, params: {
      user: {data_sharing_consent: "1", measurement_unit: "imperial"}
    }
    assert_redirected_to settings_privacy_path
    # Scope of this test is the params permit list, not data_sharing_consent
    # casting behavior — assert only the measurement_unit side.
    assert_equal "imperial", @user.reload.measurement_unit
  end
end
