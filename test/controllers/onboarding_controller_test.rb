# frozen_string_literal: true

require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.personal_account
    # Clean up any existing family profile
    @account.family_profile&.destroy
    # Reset onboarding status for these tests
    @user.update!(onboarding_completed_at: nil, onboarding_step: :family_profile)
    sign_in @user
  end

  test "should get family_profile step" do
    get onboarding_family_profile_path
    assert_response :success
    assert_select "h1", /Profilo della Famiglia|Family Profile/
  end

  test "should update family_profile and advance to children step" do
    patch onboarding_family_profile_path, params: {
      family_profile: {
        country: "Italy",
        nationality: "Italian",
        mother_tongue: "Italian",
        family_structure: "two_parents",
        number_of_children: 2,
        languages_spoken_at_home: 1
      }
    }
    assert_redirected_to onboarding_children_path
    @user.reload
    assert_equal "children", @user.onboarding_step
    assert @account.reload.family_profile.present?
  end

  test "should get children step" do
    # First complete family profile
    @account.create_family_profile!(
      country: "Italy",
      number_of_children: 1,
      languages_spoken_at_home: 1
    )
    @user.update!(onboarding_step: :children)

    get onboarding_children_path
    assert_response :success
  end

  test "should get health_history step" do
    # First complete family profile
    @account.create_family_profile!(
      country: "Italy",
      number_of_children: 1,
      languages_spoken_at_home: 1
    )
    @user.update!(onboarding_step: :health_history)

    get onboarding_health_history_path
    assert_response :success
  end

  test "should complete onboarding" do
    # Set up prerequisites
    @account.create_family_profile!(
      country: "Italy",
      number_of_children: 1,
      languages_spoken_at_home: 1
    )
    @user.update!(onboarding_step: :health_history)

    patch onboarding_health_history_path, params: {
      family_profile: {
        primary_caregivers: ["parents"],
        has_hereditary_conditions: false
      }
    }
    assert_redirected_to onboarding_complete_path

    @user.reload
    assert @user.onboarding_completed?
  end

  test "should redirect completed user to root" do
    @user.update!(onboarding_completed_at: Time.current)

    get onboarding_family_profile_path
    assert_redirected_to root_path
  end

  test "should show complete page" do
    @user.update!(onboarding_step: :complete)
    get onboarding_complete_path
    assert_response :success
  end

  test "finish redirects to root" do
    post onboarding_finish_path
    assert_redirected_to root_path
  end

  test "redirects to family_profile when accessing children without family profile" do
    get onboarding_children_path
    assert_redirected_to onboarding_family_profile_path
  end

  test "redirects to family_profile when accessing health_history without family profile" do
    get onboarding_health_history_path
    assert_redirected_to onboarding_family_profile_path
  end
end
