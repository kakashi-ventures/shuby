# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  # Regression: when the user's personal account holds no children, the dashboard
  # must still resolve to the account that DOES hold their (active) child, instead
  # of silently landing on the empty personal account. No switch_account here on
  # purpose — that pins session[:account_id] and would bypass fallback_account.
  test "shows a child from a non-personal account when the personal account is empty" do
    user = users(:two) # owns empty personal account :two; member of :company (has children)
    assert_empty user.personal_account.children.active

    sign_in user
    get today_path

    assert_response :success
    assert_match children(:luca).display_name, response.body,
      "expected fallback_account to prefer the account holding an active child"
  end
end
