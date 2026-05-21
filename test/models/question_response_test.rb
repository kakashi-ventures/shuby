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

  # --- Session status callback ---

  test "session completes when every question answered si" do
    session = build_fresh_session(:relazione_mese_0)
    answer_all(session, :si)

    assert session.reload.completed?
    assert_not_nil session.completed_at
  end

  test "session stays in_progress when any answer is no" do
    session = build_fresh_session(:relazione_mese_0)
    questions = session.age_band_questionnaire.questions.active.to_a
    questions[0..-2].each { |q| QuestionResponse.create!(questionnaire_session: session, question: q, answer: :si) }
    QuestionResponse.create!(questionnaire_session: session, question: questions.last, answer: :no)

    assert session.reload.in_progress?
    assert_nil session.completed_at
  end

  test "session stays in_progress when any answer is incerto" do
    session = build_fresh_session(:relazione_mese_0)
    questions = session.age_band_questionnaire.questions.active.to_a
    questions[0..-2].each { |q| QuestionResponse.create!(questionnaire_session: session, question: q, answer: :si) }
    QuestionResponse.create!(questionnaire_session: session, question: questions.last, answer: :incerto)

    assert session.reload.in_progress?
    assert_nil session.completed_at
  end

  test "editing si to no on completed session demotes to in_progress and clears completed_at" do
    session = build_fresh_session(:relazione_mese_0)
    answer_all(session, :si)
    assert session.reload.completed?

    session.question_responses.first.update!(answer: :no)

    session.reload
    assert session.in_progress?
    assert_nil session.completed_at
  end

  private

  def build_fresh_session(age_band_key)
    QuestionnaireSession.create!(
      child: children(:sophia),
      age_band_questionnaire: age_band_questionnaires(age_band_key),
      status: :not_started
    )
  end

  def answer_all(session, answer)
    session.age_band_questionnaire.questions.active.each do |q|
      QuestionResponse.create!(questionnaire_session: session, question: q, answer: answer)
    end
  end
end
