# frozen_string_literal: true

require "test_helper"

class QuestionnaireSessionTest < ActiveSupport::TestCase
  test "belongs to child" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal children(:sophia), session.child
  end

  test "belongs to age_band_questionnaire" do
    session = questionnaire_sessions(:in_progress_session)
    assert_equal age_band_questionnaires(:motricita_mese_0), session.age_band_questionnaire
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
    expected = (total > 0) ? (answered.to_f / total * 100).round : 0
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

  test "incerto_count returns count of incerto answers" do
    session = questionnaire_sessions(:completed_session)
    expected = session.question_responses.where(answer: :incerto).count
    assert_equal expected, session.incerto_count
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

  test "needs_attention? returns true for in_progress session with all answered and 2+ no" do
    session = build_attention_session(no_count: 2, si_count: 1)
    assert session.in_progress?
    assert_equal session.questions_count, session.answered_count
    assert session.needs_attention?
  end

  test "needs_attention? returns false when all answered si — session is completed without alert" do
    session = build_attention_session(no_count: 0, si_count: 3)
    assert session.completed?
    assert_not session.needs_attention?
  end

  test "needs_attention? returns false for in_progress session that has not answered all questions" do
    session = questionnaire_sessions(:in_progress_session)
    assert_operator session.answered_count, :<, session.questions_count
    assert_not session.needs_attention?
  end

  test "days_until_locked returns 0 without crash for in_progress session" do
    session = questionnaire_sessions(:in_progress_session)
    assert session.editable?
    assert_nil session.completed_at
    assert_equal 0, session.days_until_locked
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

  # --- Skip logic scopes ---

  test "for_past_age returns in-progress sessions from past age bands" do
    sophia = children(:sophia)
    current_age = sophia.questionnaire_age_in_months

    past_sessions = sophia.questionnaire_sessions.for_past_age(current_age)
    assert past_sessions.any?, "Expected past in-progress sessions for sophia"
    past_sessions.each do |s|
      assert s.in_progress?
      assert_operator s.age_band_questionnaire.max_age_months, :<=, current_age
    end
  end

  test "for_past_age does not include current age sessions" do
    sophia = children(:sophia)
    current_age = sophia.questionnaire_age_in_months

    past_sessions = sophia.questionnaire_sessions.for_past_age(current_age)
    past_sessions.each do |s|
      assert_operator s.age_band_questionnaire.max_age_months, :<=, current_age
      # Current age sessions have max_age_months > current_age, so they should not appear
    end
  end

  test "stale_not_started returns not-started sessions from past age bands" do
    sophia = children(:sophia)
    current_age = sophia.questionnaire_age_in_months

    stale = sophia.questionnaire_sessions.stale_not_started(current_age)
    assert stale.any?, "Expected stale not-started sessions for sophia"
    stale.each do |s|
      assert s.not_started?
      assert_operator s.age_band_questionnaire.max_age_months, :<=, current_age
    end
  end

  test "from_past_age_band? returns true for past session" do
    session = questionnaire_sessions(:past_in_progress_session)
    sophia = children(:sophia)
    assert session.from_past_age_band?(sophia.questionnaire_age_in_months)
  end

  # --- Editability ---

  test "editable? returns true for in_progress sessions" do
    session = questionnaire_sessions(:in_progress_session)
    assert session.in_progress?
    assert session.editable?
  end

  test "editable? returns true for completed session within 14 days" do
    session = questionnaire_sessions(:completed_session)
    assert session.completed?
    assert session.editable?
  end

  test "editable? returns false for completed session past 14 day window" do
    session = questionnaire_sessions(:in_progress_session)
    session.update!(status: :completed, completed_at: 20.days.ago)
    assert_not session.editable?
  end

  test "editable? returns false for not_started sessions" do
    session = questionnaire_sessions(:not_started_session)
    assert_not session.editable?
  end

  test "from_past_age_band? returns false for current session" do
    # Create a session for current age band
    sophia = children(:sophia)
    current_q = AgeBandQuestionnaire.for_age(sophia.questionnaire_age_in_months).first
    return unless current_q # skip if no questionnaire for current age

    session = sophia.questionnaire_sessions.create!(
      age_band_questionnaire: current_q,
      status: :not_started
    )
    assert_not session.from_past_age_band?(sophia.questionnaire_age_in_months)
  end

  private

  def build_attention_session(no_count:, si_count:)
    session = QuestionnaireSession.create!(
      child: children(:sophia),
      age_band_questionnaire: age_band_questionnaires(:relazione_mese_0),
      status: :not_started
    )
    answers = Array.new(no_count, :no) + Array.new(si_count, :si)
    session.age_band_questionnaire.questions.active.zip(answers).each do |question, answer|
      QuestionResponse.create!(questionnaire_session: session, question: question, answer: answer)
    end
    session.reload
  end
end
