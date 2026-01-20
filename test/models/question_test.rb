# frozen_string_literal: true

require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "belongs to age_band_questionnaire" do
    question = questions(:m0_com_1)
    assert_equal age_band_questionnaires(:comunicazione_month_0), question.age_band_questionnaire
  end

  test "has many question_responses" do
    question = questions(:m0_com_1)
    assert_respond_to question, :question_responses
  end

  test "validates presence of prompt" do
    question = Question.new(
      age_band_questionnaire: age_band_questionnaires(:comunicazione_month_0),
      position: 0
    )
    assert_not question.valid?
    assert question.errors[:prompt].any?
  end

  test "active scope returns only active questions" do
    active_questions = Question.active
    assert active_questions.all?(&:active?)
  end

  test "ordered scope returns questions by position" do
    questions_list = Question.ordered
    positions = questions_list.pluck(:position)
    assert_equal positions, positions.sort
  end

  test "inactive question exists in fixtures" do
    inactive = questions(:inactive_question)
    assert_not inactive.active?
  end
end
