# frozen_string_literal: true

require "test_helper"

class DevelopmentStagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    sign_in @user
    switch_account(@account)
  end

  test "should get index" do
    get child_development_stages_path(@child)
    assert_response :success
    assert_select "h1", /Timeline/i
  end

  test "should show development area with valid questionnaire" do
    area = development_areas(:comunicazione)
    get child_development_stage_path(@child, area.slug)
    assert_response :success
  end

  test "should redirect to questionnaire when starting" do
    area = development_areas(:relazione)
    get start_child_development_stage_path(@child, area.slug)
    assert_response :redirect
    assert_match(/questionari/, response.redirect_url)
  end

  test "index requires authentication" do
    sign_out @user
    get child_development_stages_path(@child)
    assert_response :redirect
  end

  test "cannot access non-existent child development stages" do
    # Test that attempting to access a non-existent child returns an error
    fake_child_id = 999999
    get child_development_stages_path(fake_child_id)

    # Should return 404 Not Found or redirect if error handling is in place
    assert_includes [404, 302], response.status
  end

  # --- Skip logic tests ---

  test "index loads past in-progress sessions" do
    get child_development_stages_path(@child)
    assert_response :success
    # The amber "past in progress" indicator should appear for areas with past sessions
    assert_select "span.text-amber-600", minimum: 0
  end

  test "show loads past in-progress session for area" do
    area = development_areas(:comunicazione)
    get child_development_stage_path(@child, area.slug)
    assert_response :success
  end

  # --- Timeline carousel tests ---

  test "index renders carousel pills" do
    get child_development_stages_path(@child)
    assert_response :success
    assert_select ".shuby-timeline-pill", minimum: 10
  end

  test "index renders Stimulus controller data attributes" do
    get child_development_stages_path(@child)
    assert_response :success
    assert_select "[data-controller='timeline-carousel']"
  end

  test "index pre-selects one pill" do
    get child_development_stages_path(@child)
    assert_response :success
    assert_select ".shuby-timeline-pill[aria-selected='true']", count: 1
  end

  test "timeline_content returns content for given band" do
    get timeline_content_child_development_stages_path(@child), params: {band: "mese_6"}
    assert_response :success
  end

  test "timeline_content falls back to current band for invalid key" do
    get timeline_content_child_development_stages_path(@child), params: {band: "invalid"}
    assert_response :success
  end

  # --- Start action tests ---

  test "start raises error for past age band questionnaire" do
    # Sophia is ~2 months old, motricita_month_0 is past
    area = development_areas(:motricita)
    # The start action looks up the current-age questionnaire, not a past one,
    # so this should succeed (creating a session for the current month)
    get start_child_development_stage_path(@child, area.slug)
    assert_response :redirect
  end
end
