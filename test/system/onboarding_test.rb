require "application_system_test_case"

class OnboardingTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @account = @user.personal_account
    @account.family_profile&.destroy
    @account.children.destroy_all
    @user.update!(onboarding_completed_at: nil, onboarding_step: :setup)
    login_as @user, scope: :user
  end

  test "user completes onboarding through the form" do
    visit onboarding_path

    assert_selector "h1", text: I18n.t("onboarding.title")
    assert_selector ".shuby-radio-pill", count: 11

    fill_in "child_name", with: "Marco"
    birth_date = 6.months.ago.to_date
    page.execute_script(
      "document.getElementById('child_birth_date').value = '#{birth_date.iso8601}';"
    )
    choose I18n.t("onboarding.sex.male"), allow_label_click: true
    choose I18n.t("onboarding.relationship_options.caregiver"), allow_label_click: true
    choose "1", allow_label_click: true

    click_on I18n.t("onboarding.submit")

    assert_current_path root_path, ignore_query: true
    @user.reload
    assert_not_nil @user.onboarding_completed_at
    account_user = AccountUser.find_by(user: @user, account: @account)
    assert_equal "caregiver", account_user.relationship_to_child
    assert_equal "Marco", @account.reload.children.first.name
  end
end
