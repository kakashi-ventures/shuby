# frozen_string_literal: true

require "test_helper"

class DashboardStageContentTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test "weekly scope returns weekly rows ordered by min_age_weeks" do
    weeks = DashboardStageContent.weekly.pluck(:min_age_weeks)
    assert_equal [1, 3, 5, 7], weeks
  end

  test "monthly scope returns monthly rows ordered by min_age_months" do
    months = DashboardStageContent.monthly.pluck(:min_age_months)
    assert_equal months.sort, months
    assert_includes months, 2
    assert_includes months, 36
  end

  test "for_child returns weekly row for newborn under 8 weeks" do
    child = build_child(birth_date: 10.days.ago.to_date)
    assert_equal "Settimane 1–2", DashboardStageContent.for_child(child).label
  end

  test "for_child returns weekly row aligned to actual week" do
    child = build_child(birth_date: 22.days.ago.to_date)
    assert_equal "Settimane 3–4", DashboardStageContent.for_child(child).label
  end

  test "for_child clamps weeks 9+ in month 1 to Settimane 7-8 (rounding gap)" do
    child = build_child(birth_date: 58.days.ago.to_date)
    assert_equal 1, child.questionnaire_age_in_months
    assert_operator child.questionnaire_age_in_weeks, :>, 8
    assert_equal "Settimane 7–8", DashboardStageContent.for_child(child).label
  end

  test "for_child returns monthly row from month 2 onward" do
    # Day offsets pinned so questionnaire_age_in_months matches the target month
    # (model divides by 30.44 and floors, so calendar N.months.ago drifts).
    child = build_child(birth_date: 200.days.ago.to_date)
    assert_equal 6, child.questionnaire_age_in_months
    assert_equal "Mese 6", DashboardStageContent.for_child(child).label
  end

  test "for_child clamps over-range ages to month 36" do
    # 1200 days ≈ 39.4 months — over 36 but still within Child's 40-month upper bound.
    child = build_child(birth_date: 1200.days.ago.to_date)
    assert_operator child.questionnaire_age_in_months, :>, 36
    assert_equal "Mese 36", DashboardStageContent.for_child(child).label
  end

  test "for_child returns nil when no matching monthly row exists" do
    # Month 4: no fixture row (gap between monthly_2 and monthly_6).
    child = build_child(birth_date: 125.days.ago.to_date)
    assert_equal 4, child.questionnaire_age_in_months
    assert_nil DashboardStageContent.for_child(child)
  end

  test "weekly kind requires min/max age weeks" do
    record = DashboardStageContent.new(kind: "weekly", label: "x", body: "y")
    refute record.valid?
    assert record.errors[:min_age_weeks].any?
  end

  test "monthly kind requires min/max age months" do
    record = DashboardStageContent.new(kind: "monthly", label: "x", body: "y")
    refute record.valid?
    assert record.errors[:min_age_months].any?
  end

  test "invalid kind rejected" do
    record = DashboardStageContent.new(kind: "yearly", label: "x", body: "y")
    refute record.valid?
    assert record.errors[:kind].any?
  end

  private

  def build_child(birth_date:)
    Child.create!(account: @account, name: "Test Child", birth_date: birth_date, sex: 1, active: true)
  end
end
