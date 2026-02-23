require "test_helper"

class Madmin::GrowthPhasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @growth_phase = growth_phases(:newborn_phase)
  end

  test "should get index" do
    get madmin_growth_phases_url
    assert_response :success
    assert_select "table"
  end

  test "should get new" do
    get new_madmin_growth_phase_url
    assert_response :success
  end

  test "should create growth_phase" do
    assert_difference("GrowthPhase.count") do
      post madmin_growth_phases_url, params: {
        growth_phase: {
          title: "Nuova fase di crescita",
          description: "Descrizione della nuova fase di crescita",
          min_age_months: 6,
          max_age_months: 9,
          illustration_key: "growth-phase-mascot.svg",
          position: 3
        }
      }
    end
    assert_redirected_to madmin_growth_phase_url(GrowthPhase.last)
  end

  test "should not create growth_phase with invalid params" do
    assert_no_difference("GrowthPhase.count") do
      post madmin_growth_phases_url, params: {
        growth_phase: {
          title: "",
          description: "",
          min_age_months: -1,
          max_age_months: 0
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should show growth_phase" do
    get madmin_growth_phase_url(@growth_phase)
    assert_response :success
  end

  test "should get edit" do
    get edit_madmin_growth_phase_url(@growth_phase)
    assert_response :success
  end

  test "should update growth_phase" do
    patch madmin_growth_phase_url(@growth_phase), params: {
      growth_phase: {
        title: "Titolo aggiornato"
      }
    }
    assert_redirected_to madmin_growth_phase_url(@growth_phase)
    @growth_phase.reload
    assert_equal "Titolo aggiornato", @growth_phase.title
  end

  test "should destroy growth_phase" do
    assert_difference("GrowthPhase.count", -1) do
      delete madmin_growth_phase_url(@growth_phase)
    end
    assert_redirected_to madmin_growth_phases_url
  end

  test "non-admin users cannot access index" do
    sign_out @admin
    sign_in users(:two)
    get madmin_growth_phases_url
    assert_response :not_found
  end
end
