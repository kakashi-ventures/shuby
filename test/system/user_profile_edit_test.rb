require "application_system_test_case"

class UserProfileEditTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
  end

  test "renders the brand-aligned profile edit page" do
    visit edit_user_registration_path

    assert_selector ".shuby-back-link"
    assert_selector "h1.shuby-h3", text: I18n.t("devise.registrations.edit.title")
    assert_selector ".shuby-avatar-upload-preview"
    assert_selector "input.shuby-input[name='user[first_name]']"
    assert_selector "input.shuby-input[name='user[last_name]']"
    assert_selector "input.shuby-input[name='user[email]']"
    assert_selector "button.shuby-btn-primary.shuby-btn-lg.w-full"

    assert_no_selector ".shuby-btn-danger-subtle"
    assert_no_selector "input.form-control"
    assert_no_selector "input[name='user[name]']"
  end

  test "updates first_name and last_name" do
    visit edit_user_registration_path
    fill_in "user[first_name]", with: "Faezeh"
    fill_in "user[last_name]", with: "Kakashi"
    click_button I18n.t("devise.registrations.edit.update")

    using_wait_time(5) do
      assert_no_text I18n.t("devise.registrations.edit.saving")
    end

    @user.reload
    assert_equal "Faezeh", @user.first_name
    assert_equal "Kakashi", @user.last_name
  end
end
