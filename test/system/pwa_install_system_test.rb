# frozen_string_literal: true

require "application_system_test_case"

# In-app PWA install surfaces. beforeinstallprompt cannot be triggered for
# real in Selenium, so the install→native-dialog path isn't covered here; we
# exercise the instructions sheet (the iOS / no-prompt path), the banner
# reveal+dismiss lifecycle (driven by a synthetic beforeinstallprompt), and
# the standalone CSS hide. See .claude/rules/bottom-sheet-overlays.md.
class PwaInstallSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
  end

  INSTALL_TRIGGER = "[data-action='pwa-install#install']"
  BANNER = "[data-pwa-install-target='banner']"
  OVERLAY = "[data-pwa-install-target='overlay']"
  SHEET = "[data-pwa-install-target='sheet']"
  DISMISS = "[data-action='pwa-install#dismiss']"

  # === Instructions sheet (settings row) ===

  test "settings install row opens the instructions sheet; Escape closes it" do
    visit settings_path(tab: "configuration")
    assert_selector INSTALL_TRIGGER, visible: true

    find(INSTALL_TRIGGER).click

    assert_selector "#{OVERLAY}.shuby-bottom-sheet--open"
    assert_selector "#{SHEET}[role=dialog][aria-modal=true]"
    # Non-iOS browser → the generic browser-menu steps are the visible list.
    assert_text I18n.t("pwa.install.sheet.generic_steps").first

    find("body").send_keys(:escape)
    assert_no_selector "#{OVERLAY}.shuby-bottom-sheet--open"
  end

  test "backdrop click closes the instructions sheet" do
    visit settings_path(tab: "configuration")
    find(INSTALL_TRIGGER).click
    assert_selector "#{OVERLAY}.shuby-bottom-sheet--open"

    # Dispatch the click on the backdrop element itself so event.target ==
    # currentTarget (closeOnBackdrop), bypassing the sheet's overlap.
    page.execute_script("document.querySelector(\"#{OVERLAY} .shuby-bottom-sheet-backdrop\").click()")

    assert_no_selector "#{OVERLAY}.shuby-bottom-sheet--open"
  end

  # === Dashboard banner lifecycle ===

  test "banner reveals on beforeinstallprompt and stays hidden after dismiss" do
    visit today_path

    # Hidden on load: no prompt captured yet and this isn't iOS.
    assert_no_selector BANNER, visible: true

    # A captured beforeinstallprompt makes the app installable → banner shows.
    page.execute_script("window.dispatchEvent(new Event('beforeinstallprompt'))")
    assert_selector BANNER, visible: true

    find(DISMISS).click
    assert_no_selector BANNER, visible: true

    # Dismiss persists (localStorage cooldown): re-firing installable keeps it
    # hidden.
    page.execute_script("window.dispatchEvent(new Event('beforeinstallprompt'))")
    assert_no_selector BANNER, visible: true
  end

  # === Standalone (installed PWA) hide ===

  test "install surfaces hide when running as an installed PWA" do
    visit settings_path(tab: "configuration")
    assert_selector INSTALL_TRIGGER, visible: true

    # The inline head script adds this class for installed PWAs; simulate it.
    page.execute_script("document.documentElement.classList.add('pwa-standalone')")

    assert_no_selector INSTALL_TRIGGER, visible: true
  end
end
