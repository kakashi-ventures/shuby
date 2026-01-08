# frozen_string_literal: true

require "test_helper"

class QuestionnaireSessionTest < ActiveSupport::TestCase
  test "belongs to child" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal children(:sophia), session.child
  end

  test "belongs to age_band_questionnaire" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal age_band_questionnaires(:motricita_0_3), session.age_band_questionnaire
  end

  test "has many question_responses" do
    session = questionnaire_sessions(:in_progress_session)
    assert_respond_to session, :question_responses
    assert session.question_responses.count > 0
  end

  test "status enum values" do
    assert_equal 0, QuestionnaireSession.statuses[:not_started]
    assert_equal 1, QuestionnaireSession.statuses[:in_progress]
    assert_equal 2, QuestionnaireSession.statuses[:completed]
  end

  test "in_progress scope returns in_progress sessions" do
    sessions = QuestionnaireSession.in_progress
    assert sessions.all?(&:in_progress?)
  end

  test "completed scope returns completed sessions" do
    sessions = QuestionnaireSession.completed
    assert sessions.all?(&:completed?)
  end

  test "total_questions returns count of active questions" do
    session = questionnaire_sessions(:in_progress_session)
    expected_count = session.age_band_questionnaire.questions.active.count
    assert_equal expected_count, session.total_questions
  end

  test "answered_count returns number of responses" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal session.question_responses.count, session.answered_count
  end

  test "progress_percentage calculates correctly" do
    session = questionnaire_sessions(:in_progress_session)
    total = session.total_questions
    answered = session.answered_count
    expected = total > 0 ? (answered.to_f / total * 100).round : 0
    assert_equal expected, session.progress_percentage
  end

  test "si_count returns count of si answers" do
    session = questionnaire_sessions(:completed_session)
    expected = session.question_responses.where(answer: :si).count
    assert_equal expected, session.si_count
  end

  test "no_count returns count of no answers" do
    session = questionnaire_sessions(:attention_needed_session)
    expected = session.question_responses.where(answer: :no).count
    assert_equal expected, session.no_count
  end

  test "non_lo_so_count returns count of non_lo_so answers" do
    session = questionnaire_sessions(:completed_session)
    expected = session.question_responses.where(answer: :non_lo_so).count
    assert_equal expected, session.non_lo_so_count
  end

  test "needs_attention? returns true when 2 or more no answers" do
    session = questionnaire_sessions(:attention_needed_session)
    assert session.needs_attention?
  end

  test "needs_attention? returns false for not completed session" do
    session = questionnaire_sessions(:in_progress_session)
    assert_not session.needs_attention?
  end

  test "needs_attention? returns false when few no answers" do
    session = questionnaire_sessions(:completed_session)
    assert_not session.needs_attention?
  end

  test "next_unanswered_question returns unanswered question" do
    session = questionnaire_sessions(:in_progress_session)
    next_q = session.next_unanswered_question
    assert_not_nil next_q
    answered_ids = session.question_responses.pluck(:question_id)
    assert_not_includes answered_ids, next_q.id
  end

  test "next_unanswered_question returns nil when all answered" do
    session = questionnaire_sessions(:completed_session)
    # This session has all questions answered
    next_q = session.next_unanswered_question
    assert_nil next_q
  end

  test "development_area returns associated development area" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal development_areas(:motricita), session.development_area
  end

  test "mark_in_progress! updates status and started_at" do
    session = questionnaire_sessions(:not_started_session)
    session.mark_in_progress!
    assert session.in_progress?
    assert_not_nil session.started_at
  end

  test "mark_completed! updates status and completed_at" do
    session = questionnaire_sessions(:in_progress_session)
    session.mark_completed!
    assert session.completed?
    assert_not_nil session.completed_at
  end
end
