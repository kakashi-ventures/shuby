require "application_system_test_case"

class SettingsPlanTabTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as @user, scope: :user
  end

  test "renders the brand-aligned plan tab" do
    visit settings_path(tab: "plan")

    assert_no_selector "h1", text: I18n.t("pricing.show.heading")

    assert_no_selector ".btn.btn-secondary.btn-large.btn-block"

    if Plan.visible.any?
      assert_selector ".shuby-card", minimum: 1
      assert_selector "a.shuby-btn-primary, span.shuby-tag-info"
    end
  end

  test "plan card count matches visible monthly plans (mirrors admin/plans)" do
    visit settings_path(tab: "plan")
    visible_monthly_count = Plan.visible.partition(&:monthly?)[0].count
    assert_selector ".shuby-card", count: visible_monthly_count if visible_monthly_count.positive?
  end

  test "GET /pricing redirects to /settings?tab=plan" do
    visit "/pricing"
    assert_current_path settings_path(tab: "plan")
  end
end
