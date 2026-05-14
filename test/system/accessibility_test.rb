# frozen_string_literal: true

require "application_system_test_case"

# WCAG 2.1 Level AA regression suite. Runs axe-core inside the headless
# Chrome session against the highest-traffic flows. New violations on
# any of these pages should fail CI before they reach main.
#
# When a new page is added that materially changes the chrome (a new
# layout, a new modal pattern), add a flow here so the regression
# guarantee covers it too. Per-flow `skip_rules:` arguments are last-
# resort escape hatches — document the reason inline.
class AccessibilityTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @child = children(:emma)
  end

  test "sign-in page meets WCAG 2.1 AA" do
    visit new_user_session_path
    assert_selector "form" # ensure page rendered
    assert_accessible
  end

  test "dashboard / Oggi tab meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit today_path
    assert_selector "main"
    assert_accessible
  end

  test "timeline meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit child_development_stages_path(@child)
    assert_selector "main"
    assert_accessible
  end

  test "archive index meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit archive_index_path
    assert_selector "main"
    assert_accessible
  end

  test "measurements tab meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit child_path(@child, tab: "measurements")
    assert_selector "main"
    assert_accessible
  end

  test "shuby chat index meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit shuby_chats_path
    assert_selector "main"
    assert_accessible
  end

  test "settings — Famiglia tab meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit settings_path
    assert_selector "main"
    assert_accessible
  end

  test "child profile show meets WCAG 2.1 AA" do
    login_as @user, scope: :user
    visit child_path(@child)
    assert_selector "main"
    assert_accessible
  end
end
