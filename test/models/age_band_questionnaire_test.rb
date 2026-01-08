# frozen_string_literal: true

require "test_helper"

class AgeBandQuestionnairTest < ActiveSupport::TestCase
  test "belongs to development_area" do
    questionnaire = age_band_questionnaires(:generale_0_3)
    assert_equal development_areas(:generale), questionnaire.development_area
  end

  test "has many questions" do
    questionnaire = age_band_questionnaires(:generale_0_3)
    assert_respond_to questionnaire, :questions
    assert questionnaire.questions.count > 0
  end

  test "has many questionnaire_sessions" do
    questionnaire = age_band_questionnaires(:generale_0_3)
    assert_respond_to questionnaire, :questionnaire_sessions
  end

  test "validates presence of min_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:generale),
      max_age_months: 3
    )
    assert_not questionnaire.valid?
    assert_includes questionnaire.errors[:min_age_months], "can't be blank"
  end

  test "validates presence of max_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:generale),
      min_age_months: 0
    )
    assert_not questionnaire.valid?
    assert_includes questionnaire.errors[:max_age_months], "can't be blank"
  end

  test "age_band_label returns formatted string" do
    questionnaire = age_band_questionnaires(:generale_0_3)
    assert_equal "0-3 mesi", questionnaire.age_band_label
  end

  test "active_questions returns only active questions" do
    questionnaire = age_band_questionnaires(:generale_0_3)
    active_questions = questionnaire.active_questions
    assert active_questions.all?(&:active?)
  end
end
