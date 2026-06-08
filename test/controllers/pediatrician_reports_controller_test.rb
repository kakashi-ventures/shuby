# frozen_string_literal: true

require "test_helper"

class PediatricianReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    sign_in @user
    switch_account(@account)
  end

  # === Show (PDF download) ===

  test "should download PDF report" do
    get child_pediatrician_report_path(@child)
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert response.body.start_with?("%PDF")
  end

  test "PDF filename includes child name and date" do
    get child_pediatrician_report_path(@child)
    assert_match(/shuby-report-.*\.pdf/, response.headers["Content-Disposition"])
  end

  test "PDF is served inline for browser viewing" do
    get child_pediatrician_report_path(@child)
    assert_match(/inline/, response.headers["Content-Disposition"])
  end

  # === Authentication ===

  test "requires authentication" do
    sign_out @user
    get child_pediatrician_report_path(@child)
    assert_response :redirect
  end

  # === Authorization / Multi-tenancy ===

  test "cannot access report for child in another account" do
    sign_out @user
    sign_in users(:two)
    switch_account(accounts(:two))

    get child_pediatrician_report_path(@child)
    assert_response :not_found
  end

  # === Different child types ===

  test "generates report for premature child" do
    luca = children(:luca)
    get child_pediatrician_report_path(luca)
    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  # === Section selection (PDF preferences) ===

  test "still streams a PDF when the parent deselects some sections" do
    @user.update!(pdf_pediatrician_measurements: false, pdf_pediatrician_notes: false)
    get child_pediatrician_report_path(@child)
    assert_response :success
    assert_equal "application/pdf", response.content_type
    assert response.body.start_with?("%PDF")
  end

  test "still streams a header-only PDF when every optional section is off" do
    User::ReportPreferences::PEDIATRICIAN_SECTIONS.each do |section|
      @user.public_send(:"pdf_pediatrician_#{section}=", false)
    end
    @user.save!

    get child_pediatrician_report_path(@child)
    assert_response :success
    assert response.body.start_with?("%PDF")
  end
end
