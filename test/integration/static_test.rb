require "test_helper"

class Jumpstart::StaticTest < ActionDispatch::IntegrationTest
  test "unauthenticated root shows the sign-in form" do
    get root_path
    assert_response :success
    assert_select "form[action=?]", user_session_path
    assert_select "input[name=?]", "user[email]"
  end

  test "dashboard" do
    sign_in users(:one)
    get root_path
    assert_select "h1", I18n.t("dashboard.show.title")
  end
end
