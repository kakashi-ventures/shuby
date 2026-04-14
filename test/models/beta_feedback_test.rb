# frozen_string_literal: true

require "test_helper"

class BetaFeedbackTest < ActiveSupport::TestCase
  # === Validations ===

  test "valid feedback" do
    f = BetaFeedback.new(
      user: users(:one),
      account: accounts(:one),
      page_url: "/today",
      section: "dashboard",
      feedback_type: :bug,
      description: "Il pulsante non risponde al tap"
    )
    assert f.valid?
  end

  test "requires page_url" do
    f = BetaFeedback.new(user: users(:one), account: accounts(:one), section: "dashboard", feedback_type: :bug, description: "Problema con il tap sul pulsante")
    assert_not f.valid?
    assert f.errors[:page_url].any?
  end

  test "requires section" do
    f = BetaFeedback.new(user: users(:one), account: accounts(:one), page_url: "/today", feedback_type: :bug, description: "Problema con il tap sul pulsante")
    assert_not f.valid?
    assert f.errors[:section].any?
  end

  test "requires description" do
    f = BetaFeedback.new(user: users(:one), account: accounts(:one), page_url: "/today", section: "dashboard", feedback_type: :bug)
    assert_not f.valid?
    assert f.errors[:description].any?
  end

  test "description minimum length is 10" do
    f = BetaFeedback.new(user: users(:one), account: accounts(:one), page_url: "/today", section: "dashboard", feedback_type: :bug, description: "Corto")
    assert_not f.valid?
    assert f.errors[:description].any?
  end

  test "requires feedback_type" do
    f = BetaFeedback.new(user: users(:one), account: accounts(:one), page_url: "/today", section: "dashboard", description: "Problema con il pulsante della dashboard")
    f.feedback_type = nil
    assert_not f.valid?
    assert f.errors[:feedback_type].any?
  end

  # === Enums ===

  test "feedback_type enum values" do
    expected = {"bug" => 0, "suggestion" => 1, "praise" => 2, "other" => 3}
    assert_equal expected, BetaFeedback.feedback_types
  end

  test "severity enum values" do
    expected = {"low" => 0, "medium" => 1, "high" => 2, "critical" => 3}
    assert_equal expected, BetaFeedback.severities
  end

  test "status enum values" do
    expected = {"new_feedback" => 0, "in_review" => 1, "resolved" => 2, "wont_fix" => 3}
    assert_equal expected, BetaFeedback.statuses
  end

  # === Scopes ===

  test "ordered scope returns newest first" do
    feedbacks = BetaFeedback.ordered
    return if feedbacks.size < 2
    assert feedbacks.first.created_at >= feedbacks.last.created_at
  end

  test "unresolved scope excludes resolved and wont_fix" do
    unresolved = BetaFeedback.unresolved
    assert unresolved.none? { |f| f.status_resolved? || f.status_wont_fix? }
  end

  test "by_section scope filters correctly" do
    results = BetaFeedback.by_section("dashboard")
    assert results.all? { |f| f.section == "dashboard" }
  end

  # === Section mapping ===

  test "section_from_path maps root to dashboard" do
    assert_equal "dashboard", BetaFeedback.section_from_path("/")
    assert_equal "dashboard", BetaFeedback.section_from_path("/today")
  end

  test "section_from_path maps top-level routes" do
    assert_equal "archive", BetaFeedback.section_from_path("/archive")
    assert_equal "shuby", BetaFeedback.section_from_path("/shuby")
    assert_equal "settings", BetaFeedback.section_from_path("/settings")
    assert_equal "onboarding", BetaFeedback.section_from_path("/onboarding")
  end

  test "section_from_path maps nested child routes" do
    assert_equal "children", BetaFeedback.section_from_path("/children/1")
    assert_equal "measurements", BetaFeedback.section_from_path("/children/1/measurements")
    assert_equal "questionnaires", BetaFeedback.section_from_path("/children/1/questionnaires")
    assert_equal "development_stages", BetaFeedback.section_from_path("/children/1/development-stages")
  end

  test "section_from_path returns other for unknown paths" do
    assert_equal "other", BetaFeedback.section_from_path("/unknown/page")
  end

  test "section_from_path handles blank input" do
    assert_equal "dashboard", BetaFeedback.section_from_path(nil)
    assert_equal "dashboard", BetaFeedback.section_from_path("")
  end

  # === Display helpers ===

  test "section_display_name returns Italian label" do
    f = beta_feedbacks(:one)
    assert_equal "Oggi", f.section_display_name
  end

  test "section_display_name falls back to humanize" do
    f = BetaFeedback.new(section: "unknown_section")
    assert_equal "Unknown section", f.section_display_name
  end
end
