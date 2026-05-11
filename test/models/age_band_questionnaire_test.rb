# frozen_string_literal: true

require "test_helper"

class AgeBandQuestionnairTest < ActiveSupport::TestCase
  test "belongs to development_area" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_0)
    assert_equal development_areas(:comunicazione), questionnaire.development_area
  end

  test "has many questions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_0)
    assert_respond_to questionnaire, :questions
    assert questionnaire.questions.count > 0
  end

  test "has many questionnaire_sessions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_0)
    assert_respond_to questionnaire, :questionnaire_sessions
  end

  test "validates presence of min_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:comunicazione),
      max_age_months: 3
    )
    assert_not questionnaire.valid?
    assert questionnaire.errors[:min_age_months].any?
  end

  test "validates presence of max_age_months" do
    questionnaire = AgeBandQuestionnaire.new(
      development_area: development_areas(:comunicazione),
      min_age_months: 10
    )
    assert_not questionnaire.valid?
    assert questionnaire.errors[:max_age_months].any?
  end

  test "age_band_label returns label column value" do
    assert_equal "Neonato", age_band_questionnaires(:comunicazione_mese_0).age_band_label
    assert_equal "3° Mese", age_band_questionnaires(:comunicazione_mese_3).age_band_label
    assert_equal "18° Mese", age_band_questionnaires(:comunicazione_mese_18).age_band_label
    assert_equal "29-36° Mesi", age_band_questionnaires(:comunicazione_mese_28_carryover).age_band_label
  end

  test "label column is present and non-blank on all fixtures" do
    AgeBandQuestionnaire.find_each do |q|
      assert q.label.present?, "Expected label to be present for AgeBandQuestionnaire id=#{q.id}"
    end
  end

  test "active_questions returns only active questions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_0)
    active_questions = questionnaire.active_questions
    assert active_questions.all?(&:active?)
  end

  test "for_age scope returns correct monthly band" do
    # age 0 → Neonato band (min=0, max=1)
    assert_equal [0], AgeBandQuestionnaire.for_age(0).pluck(:min_age_months).uniq
    # age 3 → 3° Mese band (min=3, max=4)
    assert_equal [3], AgeBandQuestionnaire.for_age(3).pluck(:min_age_months).uniq
    # age 30 → carryover band (min=28, max=37)
    assert_equal [28], AgeBandQuestionnaire.for_age(30).pluck(:min_age_months).uniq
  end
end
