# frozen_string_literal: true

require "test_helper"

class QuestionResponseTest < ActiveSupport::TestCase
  test "belongs to questionnaire_session" do
    response = question_responses(:motricita_response_1)
    assert_equal questionnaire_sessions(:in_progress_session), response.questionnaire_session
  end

  test "belongs to question" do
    response = question_responses(:motricita_response_1)
    assert_equal questions(:m0_mot_1), response.question
  end

  test "answer enum values" do
    assert_equal 0, QuestionResponse.answers[:incerto]
    assert_equal 1, QuestionResponse.answers[:si]
    assert_equal 2, QuestionResponse.answers[:no]
  end

  test "validates presence of answer" do
    response = QuestionResponse.new(
      questionnaire_session: questionnaire_sessions(:in_progress_session),
      question: questions(:m0_mot_3),
      answer: nil
    )
    assert_not response.valid?
    assert response.errors[:answer].any?
  end

  test "validates uniqueness of question per session" do
    existing = question_responses(:motricita_response_1)
    duplicate = QuestionResponse.new(
      questionnaire_session: existing.questionnaire_session,
      question: existing.question,
      answer: :no
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:question_id].any?
  end

  test "si answer is stored correctly" do
    response = question_responses(:motricita_response_1)
    assert response.si?
  end

  test "no answer is stored correctly" do
    response = question_responses(:cognizione_response_1)
    assert response.no?
  end

  test "incerto answer is stored correctly" do
    response = question_responses(:comunicazione_response_3)
    assert response.incerto?
  end
end
