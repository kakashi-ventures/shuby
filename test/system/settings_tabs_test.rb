require "application_system_test_case"

class SettingsTabsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
  end

  test "user can switch between Famiglia, Piano, and Impostazioni tabs" do
    visit settings_path

    assert_selector "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.family")
    # Section headings render via .shuby-overline-dark which uppercases via CSS;
    # Capybara reads the rendered (uppercased) text — match accordingly.
    assert_text "ADULTI"
    assert_text "BAMBINI"

    click_on I18n.t("settings.show.tabs.plan")

    assert_selector "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.plan")
    # Plan tab inlines the /pricing template — assert pricing heading present.
    assert_text I18n.t("pricing.show.heading")

    click_on I18n.t("settings.show.tabs.configuration")

    assert_selector "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.configuration")
    assert_text "NOTIFICHE"
    assert_text "ACCOUNT"
    assert_text "SECURITY"
    assert_text "AVANZATE"

    click_on I18n.t("settings.show.tabs.family")

    assert_selector "nav.shuby-tab-segmented a.active", text: I18n.t("settings.show.tabs.family")
    assert_text "ADULTI"
  end

  test "Avanzate data-sharing toggle persists across reloads" do
    @user.update!(data_sharing_consent: false)
    visit settings_path(tab: "configuration")

    # form_with check_box emits a hidden value="0" input plus the visible
    # value="1" checkbox — scope to type=checkbox to grab only the toggle.
    toggle = find("input[type=checkbox][name='user[data_sharing_consent]']", visible: false)
    assert_equal false, toggle.checked?

    # The checkbox is sr-only; clicking the wrapping .shuby-toggle label fires
    # the auto-submit that the helper wires via onchange on the input.
    check "user[data_sharing_consent]", allow_label_click: true

    visit settings_path(tab: "configuration")

    toggle = find("input[type=checkbox][name='user[data_sharing_consent]']", visible: false)
    assert_equal true, toggle.checked?
  end
end
