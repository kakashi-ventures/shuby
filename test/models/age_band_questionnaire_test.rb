# frozen_string_literal: true

require "test_helper"

class AgeBandQuestionnairTest < ActiveSupport::TestCase
  test "belongs to development_area" do
    questionnaire = age_band_questionnaires(:comunicazione_month_0)
    assert_equal development_areas(:comunicazione), questionnaire.development_area
  end

  test "has many questions" do
    questionnaire = age_band_questionnaires(:comunicazione_month_0)
    assert_respond_to questionnaire, :questions
    assert questionnaire.questions.count > 0
  end

  test "has many questionnaire_sessions" do
    questionnaire = age_band_questionnaires(:comunicazione_month_0)
    assert_respond_to questionnaire, :questionnaire_sessions
  end

  test "validates presence of min_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:comunicazione),
      max_age_months: 3
    )
    assert_not questionnaire.valid?
    assert_includes questionnaire.errors[:min_age_months], "can't be blank"
  end

  test "validates presence of max_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:comunicazione),
      min_age_months: 10
    )
    assert_not questionnaire.valid?
    assert_includes questionnaire.errors[:max_age_months], "can't be blank"
  end

  test "age_band_label returns formatted string for monthly questionnaire" do
    questionnaire = age_band_questionnaires(:comunicazione_month_0)
    I18n.with_locale(:it) do
      assert_equal "0 mesi", questionnaire.age_band_label
    end
  end

  test "age_band_label returns singular mese for month 1" do
    questionnaire = age_band_questionnaires(:comunicazione_month_1)
    I18n.with_locale(:it) do
      assert_equal "1 mese", questionnaire.age_band_label
    end
  end

  test "active_questions returns only active questions" do
    questionnaire = age_band_questionnaires(:comunicazione_month_0)
    active_questions = questionnaire.active_questions
    assert active_questions.all?(&:active?)
  end
end
