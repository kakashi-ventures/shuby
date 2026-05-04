require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "GET /terms renders Italian terms" do
    get terms_path
    assert_response :success
    assert_includes response.body, "Termini e Condizioni"
    assert_includes response.body, "Shuby S.r.l."
    assert_includes response.body, "shuby-article-body"
  end

  test "GET /privacy renders Italian privacy policy" do
    get privacy_path
    assert_response :success
    assert_includes response.body, "Informativa Privacy"
    assert_includes response.body, "GDPR"
    assert_includes response.body, "Shuby S.r.l."
  end

  test "GET /consenso-informato renders Italian informed consent" do
    get consenso_informato_path
    assert_response :success
    assert_includes response.body, "Modulo di Consenso Informato"
    assert_includes response.body, "art. 9 GDPR"
    assert_includes response.body, "Shuby S.r.l."
  end

  test "consenso_informato action assigns informed_consent agreement" do
    get consenso_informato_path
    agreement = controller.instance_variable_get(:@agreement)
    assert_not_nil agreement
    assert_equal :informed_consent, agreement.id
  end
end
