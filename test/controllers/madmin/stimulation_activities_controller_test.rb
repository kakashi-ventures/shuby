require "test_helper"

class Madmin::StimulationActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @activity = stimulation_activities(:month_0_activity_1)
  end

  test "should get index" do
    get madmin_stimulation_activities_url
    assert_response :success
    assert_select "table"
  end

  test "should get new" do
    get new_madmin_stimulation_activity_url
    assert_response :success
  end

  test "should create stimulation_activity" do
    assert_difference("StimulationActivity.count") do
      post madmin_stimulation_activities_url, params: {
        stimulation_activity: {
          month: 6,
          description: "Nuova attività di stimolazione per il mese 6",
          position: 0
        }
      }
    end
    assert_redirected_to madmin_stimulation_activity_url(StimulationActivity.last)
  end

  test "should show stimulation_activity" do
    get madmin_stimulation_activity_url(@activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_madmin_stimulation_activity_url(@activity)
    assert_response :success
  end

  test "should update stimulation_activity" do
    patch madmin_stimulation_activity_url(@activity), params: {
      stimulation_activity: {
        description: "Descrizione aggiornata"
      }
    }
    assert_redirected_to madmin_stimulation_activity_url(@activity)
    @activity.reload
    assert_equal "Descrizione aggiornata", @activity.description
  end

  test "should destroy stimulation_activity" do
    assert_difference("StimulationActivity.count", -1) do
      delete madmin_stimulation_activity_url(@activity)
    end
    assert_redirected_to madmin_stimulation_activities_url
  end

  test "non-admin users cannot access index" do
    sign_out @admin
    sign_in users(:two)
    get madmin_stimulation_activities_url
    assert_response :not_found
  end
end
