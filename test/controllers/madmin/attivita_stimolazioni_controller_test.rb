require "test_helper"

class Madmin::AttivitaStimolazioniControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @attivita = attivita_stimolazione(:month_0_activity_1)
  end

  test "should get index" do
    get madmin_attivita_stimolazioni_url
    assert_response :success
    assert_select "table"
  end

  test "should get new" do
    get new_madmin_attivita_stimolazione_url
    assert_response :success
  end

  test "should create attivita_stimolazione" do
    assert_difference("AttivitaStimolazione.count") do
      post madmin_attivita_stimolazioni_url, params: {
        attivita_stimolazione: {
          month: 6,
          description: "Nuova attività di stimolazione per il mese 6",
          position: 0
        }
      }
    end
    assert_redirected_to madmin_attivita_stimolazione_url(AttivitaStimolazione.last)
  end

  test "should show attivita_stimolazione" do
    get madmin_attivita_stimolazione_url(@attivita)
    assert_response :success
  end

  test "should get edit" do
    get edit_madmin_attivita_stimolazione_url(@attivita)
    assert_response :success
  end

  test "should update attivita_stimolazione" do
    patch madmin_attivita_stimolazione_url(@attivita), params: {
      attivita_stimolazione: {
        description: "Descrizione aggiornata"
      }
    }
    assert_redirected_to madmin_attivita_stimolazione_url(@attivita)
    @attivita.reload
    assert_equal "Descrizione aggiornata", @attivita.description
  end

  test "should destroy attivita_stimolazione" do
    assert_difference("AttivitaStimolazione.count", -1) do
      delete madmin_attivita_stimolazione_url(@attivita)
    end
    assert_redirected_to madmin_attivita_stimolazioni_url
  end

  test "non-admin users cannot access index" do
    sign_out @admin
    sign_in users(:two)
    get madmin_attivita_stimolazioni_url
    assert_response :not_found
  end
end
