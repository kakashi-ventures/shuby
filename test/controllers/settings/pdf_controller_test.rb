# frozen_string_literal: true

require "test_helper"

class Settings::PdfControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  # === Show ===

  test "show renders the PDF settings page" do
    get settings_pdf_path
    assert_response :success
    assert_includes response.body, I18n.t("settings.pdf.show.title")
  end

  # One auto-submitting toggle form per growth section + one for the stage
  # report, all posting to settings_pdf_path (proves the toggle url: wiring).
  test "show renders a toggle form per preference, all posting to settings_pdf_path" do
    get settings_pdf_path
    assert_select "form[action=?]", settings_pdf_path,
      count: User::ReportPreferences::BOOLEAN_KEYS.size
  end

  # Settings routes sit inside the `authenticated :user` routing constraint, so
  # a signed-out request matches no route (404) rather than redirecting.
  test "show is not reachable when signed out" do
    sign_out @user
    get settings_pdf_path
    assert_response :not_found
  end

  # === Update ===

  test "update persists a deselected growth section" do
    patch settings_pdf_path, params: {user: {pdf_pediatrician_measurements: "0"}}
    assert_redirected_to settings_pdf_path
    assert_equal false, @user.reload.pdf_pediatrician_measurements
  end

  test "update persists the stage question-detail toggle" do
    patch settings_pdf_path, params: {user: {pdf_stage_question_details: "0"}}
    assert_redirected_to settings_pdf_path
    assert_equal false, @user.reload.pdf_stage_question_details
  end

  test "update permits every report preference key" do
    params = User::ReportPreferences::BOOLEAN_KEYS.index_with { "0" }
    patch settings_pdf_path, params: {user: params}
    assert_redirected_to settings_pdf_path

    @user.reload
    User::ReportPreferences::BOOLEAN_KEYS.each do |key|
      assert_equal false, @user.public_send(key), "#{key} was not persisted"
    end
  end

  # A Turbo form submit must get 204 so the page is not re-fetched/swapped on
  # every toggle (which otherwise replays the "detail" page transition).
  test "update responds 204 to a Turbo Stream toggle instead of redirecting" do
    patch settings_pdf_path,
      params: {user: {pdf_pediatrician_notes: "0"}},
      headers: {"Accept" => "text/vnd.turbo-stream.html"}
    assert_response :no_content
    assert_equal false, @user.reload.pdf_pediatrician_notes
  end

  test "update responds head :no_content for JSON requests" do
    patch settings_pdf_path,
      params: {user: {pdf_pediatrician_notes: "0"}}.to_json,
      headers: {"Content-Type" => "application/json", "Accept" => "application/json"}
    assert_response :no_content
    assert_equal false, @user.reload.pdf_pediatrician_notes
  end

  test "update is not reachable when signed out" do
    sign_out @user
    patch settings_pdf_path, params: {user: {pdf_pediatrician_notes: "0"}}
    assert_response :not_found
  end
end
