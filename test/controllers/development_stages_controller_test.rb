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
    assert_select "h1", /Development Stages/i
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
    assert_match /questionari/, response.redirect_url
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
end
