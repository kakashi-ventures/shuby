require "application_system_test_case"

class AccountPasswordEditTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
  end

  test "renders the brand-aligned password edit page" do
    visit edit_account_password_path

    assert_selector ".shuby-back-link"
    assert_selector "h1.shuby-h3", text: I18n.t("account.passwords.edit.update_password")
    assert_selector "input.shuby-input[name='user[current_password]']"
    assert_selector "input.shuby-input[name='user[password]']"
    assert_selector "input.shuby-input[name='user[password_confirmation]']"
    assert_selector "button.shuby-btn-primary.shuby-btn-lg.w-full"
    assert_selector ".shuby-card", text: I18n.t("account.passwords.edit.two_factor.header")

    assert_no_selector "input.form-control"
    assert_no_selector ".btn.btn-primary"
    assert_no_link href: billing_path
  end
end
