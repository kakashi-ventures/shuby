# frozen_string_literal: true

require "test_helper"

class StageReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    sign_in @user
    switch_account(@account)
  end

  # === Show (PDF download) ===

  test "downloads the stage PDF for a reached band" do
    get child_stage_report_path(@child, "sett_1")

    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert response.body.start_with?("%PDF")
  end

  test "is served as an attachment with a stage-scoped filename" do
    get child_stage_report_path(@child, "sett_1")

    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/shuby-tappa-sett_1-.*\.pdf/, response.headers["Content-Disposition"])
  end

  # === Band resolution ===

  test "returns 404 for an unknown band key" do
    get child_stage_report_path(@child, "not_a_band")
    assert_response :not_found
  end

  test "returns 404 for a future band the child has not reached" do
    # sophia is ~2 months; mese_6 sits beyond her current band.
    get child_stage_report_path(@child, "mese_6")
    assert_response :not_found
  end

  # === Authentication ===

  test "requires authentication" do
    sign_out @user
    get child_stage_report_path(@child, "sett_1")
    assert_response :redirect
  end

  # === Authorization / Multi-tenancy ===

  test "cannot access a stage report for a child in another account" do
    sign_out @user
    sign_in users(:two)
    switch_account(accounts(:two))

    get child_stage_report_path(@child, "sett_1")
    assert_response :not_found
  end
end
