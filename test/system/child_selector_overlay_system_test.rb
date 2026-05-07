# frozen_string_literal: true

require "application_system_test_case"

class ChildSelectorOverlaySystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    # Account `:one` has Emma + Matteo active children. Emma comes first
    # under the `ordered` scope (alphabetical by name) so she's current_child
    # by default with no selection cookie set.
    @selected_child = children(:emma)
    @other_child = children(:matteo)
    login_as @user, scope: :user
  end

  def open_overlay
    visit "/today"
    find("[data-controller='child-selector-overlay'] > button").click
    assert_selector ".shuby-child-selector-overlay--open"
  end

  test "trigger opens the overlay" do
    visit "/today"

    overlay = find(".shuby-child-selector-overlay", visible: :all)
    assert_equal "true", overlay["aria-hidden"]

    find("[data-controller='child-selector-overlay'] > button").click

    assert_selector ".shuby-child-selector-overlay.shuby-child-selector-overlay--open"
    assert_selector ".shuby-child-selector-overlay-sheet[role=dialog][aria-modal=true]"
  end

  test "selected child carries the -selected modifier and Bianco avatar" do
    open_overlay

    selected_pill = find(".shuby-child-selector-pill.-selected")
    assert_includes selected_pill.text, @selected_child.display_name
    assert selected_pill.has_selector?(".shuby-avatar-btn.-bianco")
  end

  test "non-selected child does NOT have the -selected modifier" do
    open_overlay

    pills = all(".shuby-child-selector-pill")
    other_pill = pills.find { |p| p.text.include?(@other_child.display_name) }

    refute_nil other_pill, "expected to find a pill for #{@other_child.display_name}"
    refute other_pill.matches_css?(".-selected"),
      "expected #{@other_child.display_name}'s pill to render without the -selected modifier"
  end

  test "two-child stack carries -top and -bottom positional modifiers" do
    open_overlay

    assert_selector ".shuby-child-selector-pill.-top", count: 1
    assert_selector ".shuby-child-selector-pill.-bottom", count: 1
  end

  test "tapping a non-selected child posts to child_selections and updates current_child" do
    open_overlay

    pills = all(".shuby-child-selector-pill")
    other_pill = pills.find { |p| p.text.include?(@other_child.display_name) }
    other_pill.click

    # button_to issues a PATCH that redirect_back's; Capybara follows it.
    # Re-open the overlay and confirm the modifier moved.
    find("[data-controller='child-selector-overlay'] > button").click

    new_selected = find(".shuby-child-selector-pill.-selected")
    assert_includes new_selected.text, @other_child.display_name
  end

  test "primary CTA navigates to new child form" do
    # Account `:one` is a free-tier personal account capped at 1 child.
    # It already has Emma + Matteo, so policy(Child).create? returns false
    # and the "+ Aggiungi" CTA is correctly suppressed. Drop both children
    # so the count drops below the free limit and the visible-CTA branch
    # renders.
    @selected_child.destroy
    @other_child.destroy
    open_overlay

    click_on I18n.t("dashboard.header.add_child")

    assert_current_path new_child_path
  end

  test "outline tag navigates to gestione account" do
    open_overlay

    # Bottom nav (`.shuby-bottom-nav-fixed`) is hidden globally in the iOS
    # Ruby Native shell (per `hotwire_native.css`) but renders in the test
    # browser, where Selenium intercepts the click on the outline tag. JS
    # click bypasses the layered hit-test; production iOS never sees it.
    link = find_link(I18n.t("dashboard.header.account_management"))
    page.execute_script("arguments[0].click();", link)

    assert_current_path settings_path
  end

  test "backdrop click closes the overlay" do
    open_overlay

    find(".shuby-child-selector-overlay-backdrop").click

    assert_no_selector ".shuby-child-selector-overlay--open"
  end

  test "escape closes the overlay" do
    open_overlay

    find("body").send_keys(:escape)

    assert_no_selector ".shuby-child-selector-overlay--open"
  end
end
