# frozen_string_literal: true

require "test_helper"

class AgeBandQuestionnairTest < ActiveSupport::TestCase
  test "belongs to development_area" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_1)
    assert_equal development_areas(:comunicazione), questionnaire.development_area
  end

  test "has many questions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_1)
    assert_respond_to questionnaire, :questions
    assert questionnaire.questions.count > 0
  end

  test "has many questionnaire_sessions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_1)
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

  test "age_band_label returns clinical band label" do
    assert_equal "1° Mese",     age_band_questionnaires(:comunicazione_mese_1).age_band_label
    assert_equal "3° Mese",     age_band_questionnaires(:comunicazione_mese_3).age_band_label
    assert_equal "18-24° Mesi", age_band_questionnaires(:comunicazione_mese_18).age_band_label
    assert_equal "36° Mese",    age_band_questionnaires(:comunicazione_mese_36).age_band_label
  end

  test "active_questions returns only active questions" do
    questionnaire = age_band_questionnaires(:comunicazione_mese_1)
    active_questions = questionnaire.active_questions
    assert active_questions.all?(&:active?)
  end

  test "CLINICAL_BANDS covers all ages 0 through 36 without gaps" do
    (0..36).each do |month|
      band = AgeBandQuestionnaire::CLINICAL_BANDS.find { |b| month >= b[:min] && month < b[:max] }
      assert band, "No clinical band covers month #{month}"
    end
  end

  test "for_age scope returns correct clinical band" do
    # month 0 → "1° Mese" band (min=0)
    assert_equal [0], AgeBandQuestionnaire.for_age(0).pluck(:min_age_months).uniq
    # month 3 → "3° Mese" band (min=2)
    assert_equal [2], AgeBandQuestionnaire.for_age(3).pluck(:min_age_months).uniq
    # month 36 → "36° Mese" band (min=36)
    assert_equal [36], AgeBandQuestionnaire.for_age(36).pluck(:min_age_months).uniq
  end
end
