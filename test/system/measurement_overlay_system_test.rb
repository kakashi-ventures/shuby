# frozen_string_literal: true

require "application_system_test_case"

class MeasurementOverlaySystemTest < ApplicationSystemTestCase
  setup do
    # Use Emma (child in user one's personal account) so we don't need to
    # switch accounts — switch_account's extra redirect trips up the
    # Warden session helper in Selenium-driven system tests.
    @user = users(:one)
    @child = children(:emma)
    login_as @user, scope: :user
  end

  test "tapping a tracking card optimistically opens overlay with skeleton" do
    visit child_path(@child, tab: "measurements")

    # Overlay is rendered but closed before interaction.
    overlay = find(".shuby-measurement-overlay", visible: :all)
    assert_equal "true", overlay["aria-hidden"]

    # Empty-state grid renders one tracking card per measurement type.
    first(".shuby-tracking-card").click

    # Sheet is open immediately (optimistic) — skeleton visible until
    # the frame resolves, then the real form replaces it.
    assert_selector ".shuby-measurement-overlay.shuby-measurement-overlay--open"
    assert_selector ".shuby-measurement-overlay-sheet[role=dialog][aria-modal=true]"
    assert_selector "form.shuby-measurement-form", wait: 5
    assert_no_selector ".shuby-measurement-overlay-skeleton"
  end

  test "escape closes the overlay" do
    visit child_path(@child, tab: "measurements")
    first(".shuby-tracking-card").click
    assert_selector ".shuby-measurement-overlay--open"

    find("body").send_keys(:escape)

    assert_no_selector ".shuby-measurement-overlay--open"
  end

  test "backdrop click closes the overlay" do
    visit child_path(@child, tab: "measurements")
    first(".shuby-tracking-card").click
    assert_selector ".shuby-measurement-overlay--open"

    find(".shuby-measurement-overlay-backdrop").click

    assert_no_selector ".shuby-measurement-overlay--open"
  end
end
