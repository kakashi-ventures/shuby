# frozen_string_literal: true

require "application_system_test_case"

# Type-picker bottom-sheet (Figma 463:5785 / 463:5995 / 795:8492).
# Verifies the global "+" buttons (tab heading and detail header) open
# the picker, and that tapping a card chains close-picker + open-form.
class MeasurementPickerOverlaySystemTest < ApplicationSystemTestCase
  setup do
    # Same rationale as MeasurementOverlaySystemTest: Emma is in user
    # one's personal account so we avoid switch_account.
    @user = users(:one)
    @child = children(:emma)
    login_as @user, scope: :user
  end

  test "tapping the heading + on the measurements tab opens the picker" do
    visit child_path(@child, tab: "measurements")

    picker = find(".shuby-measurement-picker-overlay", visible: :all)
    assert_equal "true", picker["aria-hidden"]

    find("button[aria-label='#{I18n.t("measurements.picker.open")}']").click

    assert_selector ".shuby-measurement-picker-overlay--open"
    assert_selector ".shuby-measurement-picker-overlay-sheet[role=dialog][aria-modal=true]"
    assert_selector ".shuby-measurement-picker-overlay-title", text: I18n.t("measurements.picker.title")
    # 4 type cards visible (one per measurement_type).
    assert_selector ".shuby-measurement-picker-overlay-grid .shuby-tracking-card", count: 4
  end

  test "escape closes the picker" do
    visit child_path(@child, tab: "measurements")
    find("button[aria-label='#{I18n.t("measurements.picker.open")}']").click
    assert_selector ".shuby-measurement-picker-overlay--open"

    find("body").send_keys(:escape)

    assert_no_selector ".shuby-measurement-picker-overlay--open"
  end

  test "backdrop click closes the picker" do
    visit child_path(@child, tab: "measurements")
    find("button[aria-label='#{I18n.t("measurements.picker.open")}']").click
    assert_selector ".shuby-measurement-picker-overlay--open"

    find(".shuby-measurement-picker-overlay-backdrop").click

    assert_no_selector ".shuby-measurement-picker-overlay--open"
  end

  test "tapping a picker card closes the picker and opens the form overlay" do
    visit child_path(@child, tab: "measurements")
    find("button[aria-label='#{I18n.t("measurements.picker.open")}']").click
    assert_selector ".shuby-measurement-picker-overlay--open"

    # First card inside the picker grid (chained data-action: close picker + open form).
    find(".shuby-measurement-picker-overlay-grid .shuby-tracking-card", match: :first).click

    assert_no_selector ".shuby-measurement-picker-overlay--open"
    assert_selector ".shuby-measurement-overlay--open"
    assert_selector "form.shuby-measurement-form", wait: 5
  end

  test "detail page header + opens the picker" do
    measurement = Measurement.create!(
      child: @child,
      measurement_type: :weight,
      value: 7000,
      measured_at: 1.day.ago
    )

    visit child_measurement_path(@child, measurement)

    find("button[aria-label='#{I18n.t("measurements.show.add_more")}']").click

    assert_selector ".shuby-measurement-picker-overlay--open"
    assert_selector ".shuby-measurement-picker-overlay-grid .shuby-tracking-card", count: 4
  end

  test "tab card with data navigates to that measurement's detail page" do
    measurement = Measurement.create!(
      child: @child,
      measurement_type: :weight,
      value: 7000,
      measured_at: 1.day.ago,
      percentile: 50
    )

    visit child_path(@child, tab: "measurements")

    # Empty types are filtered out (only weight has data) — exactly one card.
    assert_selector ".shuby-measurement-card", count: 1
    find(".shuby-measurement-card").click

    # Detail page rendered for that measurement, picker overlay present but closed.
    assert_current_path child_measurement_path(@child, measurement)
    assert_selector ".shuby-measurement-detail"
    assert_no_selector ".shuby-measurement-overlay--open"
  end
end
