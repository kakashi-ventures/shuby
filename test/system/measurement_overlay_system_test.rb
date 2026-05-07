# frozen_string_literal: true

require "application_system_test_case"

# Form bottom-sheet (Figma 621:9860). The form overlay opens via the
# picker → card chain (current UX after d43eb305 removed the legacy
# empty-state grid). Direct-from-empty-state tests are dropped because
# the empty state no longer renders tracking cards.
class MeasurementOverlaySystemTest < ApplicationSystemTestCase
  setup do
    # Use Emma (child in user one's personal account) so we don't need to
    # switch accounts — switch_account's extra redirect trips up the
    # Warden session helper in Selenium-driven system tests.
    @user = users(:one)
    @child = children(:emma)
    login_as @user, scope: :user
  end

  FORM_OVERLAY = "[data-measurement-overlay-target='overlay']"
  FORM_SHEET = "[data-measurement-overlay-target='sheet']"
  PICKER_OVERLAY = "[data-measurement-picker-overlay-target='overlay']"

  def open_form_via_picker
    visit child_path(@child, tab: "measurements")
    find("button[aria-label='#{I18n.t("measurements.picker.open")}']").click
    assert_selector "#{PICKER_OVERLAY}.shuby-bottom-sheet--open"
    find(".shuby-measurement-picker-grid .shuby-tracking-card", match: :first).click
  end

  test "picker → card chain optimistically opens form overlay with skeleton" do
    visit child_path(@child, tab: "measurements")

    # Form overlay is rendered but closed before interaction.
    overlay = find(FORM_OVERLAY, visible: :all)
    assert_equal "true", overlay["aria-hidden"]

    open_form_via_picker

    # Sheet is open immediately (optimistic) — skeleton visible until the
    # frame resolves, then the real form replaces it.
    assert_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"
    assert_selector "#{FORM_SHEET}[role=dialog][aria-modal=true]"
    assert_selector "form.shuby-measurement-form", wait: 5
    assert_no_selector ".shuby-measurement-sheet-skeleton"
  end

  test "escape closes the form overlay" do
    open_form_via_picker
    assert_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"

    find("body").send_keys(:escape)

    assert_no_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"
  end

  test "backdrop click closes the form overlay" do
    open_form_via_picker
    assert_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"

    # The form overlay backdrop must be hit specifically — both overlays
    # render simultaneously, so a bare `.shuby-bottom-sheet-backdrop` would
    # be ambiguous.
    find("#{FORM_OVERLAY} .shuby-bottom-sheet-backdrop").click

    assert_no_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"
  end
end
