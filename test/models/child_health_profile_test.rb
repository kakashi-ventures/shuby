# frozen_string_literal: true

require "test_helper"

class ChildHealthProfileTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
  end

  test "valid health profile" do
    profile = ChildHealthProfile.new(
      child: @child,
      gestational_age_category: :full_term,
      current_feeding_type: :breastfeeding
    )
    assert profile.valid?
  end

  test "gestational age categories" do
    profile = ChildHealthProfile.new(child: @child)

    profile.gestational_age_category = :very_preterm
    assert profile.gestational_age_category_very_preterm?

    profile.gestational_age_category = :moderate_preterm
    assert profile.gestational_age_category_moderate_preterm?

    profile.gestational_age_category = :late_preterm_early
    assert profile.gestational_age_category_late_preterm_early?

    profile.gestational_age_category = :late_preterm_late
    assert profile.gestational_age_category_late_preterm_late?

    profile.gestational_age_category = :full_term
    assert profile.gestational_age_category_full_term?
  end

  test "premature? returns true for non-full-term" do
    profile = ChildHealthProfile.new(child: @child)

    profile.gestational_age_category = :very_preterm
    assert profile.premature?

    profile.gestational_age_category = :moderate_preterm
    assert profile.premature?

    profile.gestational_age_category = :late_preterm_early
    assert profile.premature?

    profile.gestational_age_category = :late_preterm_late
    assert profile.premature?

    profile.gestational_age_category = :full_term
    assert_not profile.premature?
  end

  test "premature? returns false when no gestational age" do
    profile = ChildHealthProfile.new(child: @child)
    assert_not profile.premature?
  end

  test "pregnancy type enum" do
    profile = ChildHealthProfile.new(child: @child)

    profile.pregnancy_type = :natural
    assert profile.pregnancy_type_natural?

    profile.pregnancy_type = :ivf_homologous
    assert profile.pregnancy_type_ivf_homologous?

    profile.pregnancy_type = :ivf_donor_egg
    assert profile.pregnancy_type_ivf_donor_egg?
  end

  test "hospitalized after birth enum" do
    profile = ChildHealthProfile.new(child: @child)

    profile.hospitalized_after_birth = :hosp_yes
    assert profile.hospitalized_after_birth_hosp_yes?

    profile.hospitalized_after_birth = :hosp_no
    assert profile.hospitalized_after_birth_hosp_no?

    profile.hospitalized_after_birth = :hosp_unknown
    assert profile.hospitalized_after_birth_hosp_unknown?
  end

  test "hearing screening result enum" do
    profile = ChildHealthProfile.new(child: @child)

    profile.hearing_screening_result = :hearing_pass
    assert profile.hearing_screening_result_hearing_pass?

    profile.hearing_screening_result = :hearing_refer
    assert profile.hearing_screening_result_hearing_refer?
  end

  test "feeding type enum" do
    profile = ChildHealthProfile.new(child: @child)

    profile.current_feeding_type = :breastfeeding
    assert profile.current_feeding_type_breastfeeding?

    profile.current_feeding_type = :formula
    assert profile.current_feeding_type_formula?

    profile.current_feeding_type = :mixed
    assert profile.current_feeding_type_mixed?
  end

  test "validates birth weight range" do
    profile = ChildHealthProfile.new(child: @child, birth_weight_grams: 0)
    assert_not profile.valid?
    assert profile.errors[:birth_weight_grams].any?

    profile.birth_weight_grams = 10001
    assert_not profile.valid?
    assert profile.errors[:birth_weight_grams].any?

    profile.birth_weight_grams = 3200
    profile.valid?
    assert_empty profile.errors[:birth_weight_grams]
  end

  test "validates sleep hours range" do
    profile = ChildHealthProfile.new(child: @child, average_sleep_hours: 0)
    assert_not profile.valid?
    assert profile.errors[:average_sleep_hours].any?

    profile.average_sleep_hours = 25
    assert_not profile.valid?
    assert profile.errors[:average_sleep_hours].any?

    profile.average_sleep_hours = 14
    profile.valid?
    assert_empty profile.errors[:average_sleep_hours]
  end

  test "birth complications list returns empty array when nil" do
    profile = ChildHealthProfile.new(child: @child)
    assert_equal [], profile.birth_complications_list
  end

  test "sleep quality issues list returns empty array when nil" do
    profile = ChildHealthProfile.new(child: @child)
    assert_equal [], profile.sleep_quality_issues_list
  end

  test "scheduled followups list returns empty array when nil" do
    profile = ChildHealthProfile.new(child: @child)
    assert_equal [], profile.scheduled_followups_list
  end

  test "stores and retrieves birth complications" do
    profile = ChildHealthProfile.create!(
      child: @child,
      birth_complications: ["respiratory_difficulties", "jaundice_phototherapy"]
    )
    profile.reload
    assert_equal ["respiratory_difficulties", "jaundice_phototherapy"], profile.birth_complications_list
  end

  test "stores and retrieves sleep quality issues" do
    profile = ChildHealthProfile.create!(
      child: @child,
      sleep_quality_issues: ["snores", "wakes_often"]
    )
    profile.reload
    assert_equal ["snores", "wakes_often"], profile.sleep_quality_issues_list
  end
end
