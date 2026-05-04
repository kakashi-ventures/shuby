require "test_helper"

class Users::AgreementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    # Invalidate acceptances so the show route renders instead of redirecting.
    @user.update_columns(
      accepted_terms_at: nil,
      accepted_privacy_at: nil,
      accepted_informed_consent_at: nil
    )
  end

  test "GET /agreements/terms_of_service renders the agreement partial" do
    get agreement_path(:terms_of_service)
    assert_response :success
    assert_includes response.body, "Termini e Condizioni"
    assert_includes response.body, I18n.t("users.agreements.show.accept")
    assert_includes response.body, I18n.t("users.agreements.show.decline")
  end

  test "GET /agreements/privacy_policy renders Italian privacy text" do
    get agreement_path(:privacy_policy)
    assert_response :success
    assert_includes response.body, "Informativa Privacy"
  end

  test "GET /agreements/informed_consent renders Italian consent text" do
    get agreement_path(:informed_consent)
    assert_response :success
    assert_includes response.body, "Modulo di Consenso Informato"
  end

  test "PATCH /agreements/:id sets the acceptance timestamp" do
    travel_to Time.current do
      patch agreement_path(:informed_consent)
      assert_response :see_other
      @user.reload
      assert_in_delta Time.current.to_f, @user.accepted_informed_consent_at.to_f, 1
    end
  end

  test "DELETE /agreements/:id signs the user out" do
    delete agreement_path(:informed_consent)
    assert_response :see_other
    assert_match(/Per continuare/, flash[:alert].to_s)
  end

  test "force re-acceptance redirects when agreement is unaccepted" do
    get root_path
    assert_redirected_to agreement_path(:terms_of_service)
  end

  test "redirects to root when user has already accepted" do
    @user.update_columns(accepted_terms_at: Time.current)
    get agreement_path(:terms_of_service)
    assert_redirected_to root_path
  end
end
