# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_with_children = users(:one)        # account :one has 2 children (Emma, Matteo)
    @user_no_children = users(:two)           # account :two has 0 children
  end

  test "show defaults to the family tab" do
    sign_in @user_with_children
    get settings_path

    assert_response :success
    assert_select "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.family")
    assert_select "h2", text: /Adulti/i
    assert_select "h2", text: /Bambini/i
  end

  test "show with tab=configuration renders the Impostazioni sections" do
    sign_in @user_with_children
    get settings_path(tab: "configuration")

    assert_response :success
    assert_select "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.configuration")
    assert_select "h2", text: /Notifiche/i
    assert_select "h2", text: /Account/i
    assert_select "h2", text: /Security/i
    assert_select "h2", text: /Avanzate/i
  end

  test "show with an unknown tab falls back to family" do
    sign_in @user_with_children
    get settings_path(tab: "banana")

    assert_response :success
    assert_select "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.family")
  end

  test "configuration tab renders the sign-out as a button_to row" do
    sign_in @user_with_children
    get settings_path(tab: "configuration")

    assert_select "form[action=?][method=?]", destroy_user_session_path, "post"
  end

  test "family tab + button always links to /children/new regardless of children limit" do
    # Under-limit account → + → /children/new
    sign_in @user_no_children
    get settings_path
    assert_select "a[href=?]", new_child_path
    assert_select "a[href=?]", pricing_path, count: 0

    # At-limit account → + still → /children/new (ChildrenController#new
    # handles the paywall on the destination, not via redirect here).
    sign_out @user_no_children
    sign_in @user_with_children
    get settings_path
    assert_select "a[href=?]", new_child_path
    assert_select "a[href=?]", pricing_path, count: 0
  end

  test "show with tab=plan renders the Plan tab as active" do
    sign_in @user_with_children
    get settings_path(tab: "plan")

    assert_response :success
    assert_select "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.plan")
  end

  test "Plan tab inlines the pricing template heading and plan cards" do
    sign_in @user_with_children
    get settings_path(tab: "plan")

    assert_select "h1", text: I18n.t("pricing.show.heading")
    # Plan fixtures: Personal + Business each appear (monthly grid). The
    # plan card partial renders the plan name in an h4.
    assert_select "h4", text: "Personal"
    assert_select "h4", text: "Business"
  end

  test "configuration tab renders all three notification toggles" do
    sign_in @user_with_children
    get settings_path(tab: "configuration")

    assert_select "input[type=checkbox][name='user[push_notifications_enabled]']"
    assert_select "input[type=checkbox][name='user[email_newsletter_enabled]']"
    assert_select "input[type=checkbox][name='user[stage_reminders_enabled]']"
  end
end
