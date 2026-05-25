# frozen_string_literal: true

require "application_system_test_case"

class ChildrenShowSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @child = children(:emma)
    @child.create_health_profile!(birth_weight_grams: 3200, birth_height_cm: 50.5)
    login_as @user, scope: :user
  end

  test "info tab renders the six Figma rows in order" do
    visit child_path(@child)

    labels = all(".shuby-info-row dt").map { |dt| dt.text.upcase }
    expected = [
      "children.show.field.name",
      "children.show.field.birth_date",
      "children.show.field.gestational_weeks",
      "children.show.field.sex_at_birth",
      "children.show.field.birth_weight_grams",
      "children.show.field.birth_height_cm"
    ].map { |k| I18n.t(k).upcase }

    assert_equal expected, labels
  end

  test "report card sits above the Informazioni card" do
    visit child_path(@child)

    cards = all(".shuby-card")
    refute_empty cards
    assert_includes cards.first.text, I18n.t("children.show.report_cta")
  end

  test "edit affordance is an icon-only button with accessible name" do
    visit child_path(@child)

    button = find(".shuby-icon-btn-azzurro")
    assert_equal I18n.t("children.show.edit_aria"), button["aria-label"]
    refute_match(/\b#{Regexp.escape(I18n.t("children.show.edit"))}\b/, button.text)
  end

  test "ultimo aggiornamento caption hides when child has no measurements" do
    @child.measurements.destroy_all
    visit child_path(@child)

    assert_no_selector ".shuby-report-card-caption"
  end

  test "missing birth_height renders an em-dash placeholder" do
    @child.health_profile.update!(birth_height_cm: nil)
    visit child_path(@child)

    row = find(".shuby-info-row", text: I18n.t("children.show.field.birth_height_cm").upcase)
    assert_includes row.text, "—"
  end
end
