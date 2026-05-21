# frozen_string_literal: true

require "test_helper"

class EquivalentAnswerPropagatorTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    @band_a = age_band_questionnaires(:motricita_mese_0)
    @band_b = age_band_questionnaires(:motricita_mese_1)

    @question_a = Question.create!(
      age_band_questionnaire: @band_a,
      prompt: "Sample overlapping prompt",
      position: 80,
      active: true,
      content_key: "overlap-test"
    )
    @question_b = Question.create!(
      age_band_questionnaire: @band_b,
      prompt: "Sample overlapping prompt",
      position: 80,
      active: true,
      content_key: "overlap-test"
    )

    @session_a = QuestionnaireSession.create!(
      child: @child,
      age_band_questionnaire: @band_a,
      status: :not_started
    )
    @session_b = QuestionnaireSession.create!(
      child: @child,
      age_band_questionnaire: @band_b,
      status: :not_started
    )
  end

  test "creates inherited si in sibling session when direct si exists" do
    QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)

    inherited = @session_b.question_responses.find_by(question: @question_b)
    assert_not_nil inherited, "expected inherited response in session B"
    assert inherited.si?
    assert inherited.inherited?
  end

  test "does not overwrite direct (non-inherited) responses" do
    QuestionResponse.create!(questionnaire_session: @session_b, question: @question_b, answer: :no, inherited: false)
    QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)

    direct = @session_b.question_responses.find_by(question: @question_b)
    assert direct.no?
    assert_not direct.inherited?
  end

  test "removes inherited rows when authoritative si is demoted" do
    response_a = QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)
    assert @session_b.question_responses.find_by(question: @question_b)&.inherited?

    response_a.update!(answer: :no)

    assert_nil @session_b.question_responses.find_by(question: @question_b)
  end

  test "removes inherited rows when authoritative response is destroyed" do
    response_a = QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)
    assert @session_b.question_responses.find_by(question: @question_b)&.inherited?

    response_a.destroy

    assert_nil @session_b.question_responses.find_by(question: @question_b)
  end

  test "blank content_key is a no-op" do
    area_id = @band_a.development_area_id
    assert_nothing_raised do
      EquivalentAnswerPropagator.recompute(content_key: nil, child: @child, development_area_id: area_id)
      EquivalentAnswerPropagator.recompute(content_key: "", child: @child, development_area_id: area_id)
    end
  end

  test "does NOT propagate across different development areas" do
    cross_band = age_band_questionnaires(:cognizione_mese_0)
    cross_question = Question.create!(
      age_band_questionnaire: cross_band,
      prompt: "Sample overlapping prompt",
      position: 80,
      active: true,
      content_key: "overlap-test"
    )
    cross_session = QuestionnaireSession.create!(child: @child, age_band_questionnaire: cross_band, status: :not_started)

    QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)

    same_area_inherited = @session_b.question_responses.find_by(question: @question_b)
    cross_area_inherited = cross_session.question_responses.find_by(question: cross_question)

    assert same_area_inherited&.inherited?, "same-area equivalent should inherit"
    assert_nil cross_area_inherited, "cross-area equivalent must NOT inherit"
  end

  test "inherited row does not trigger further propagation across 3 same-area bands" do
    band_c = age_band_questionnaires(:motricita_mese_2)
    question_c = Question.create!(
      age_band_questionnaire: band_c,
      prompt: "Sample overlapping prompt",
      position: 80,
      active: true,
      content_key: "overlap-test"
    )
    session_c = QuestionnaireSession.create!(child: @child, age_band_questionnaire: band_c, status: :not_started)

    QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)

    inherited_b = @session_b.question_responses.find_by(question: @question_b)
    inherited_c = session_c.question_responses.find_by(question: question_c)
    assert inherited_b&.inherited?
    assert inherited_c&.inherited?

    response_a = @session_a.question_responses.find_by(question: @question_a)
    response_a.update!(answer: :no)

    assert_nil @session_b.question_responses.find_by(question: @question_b)
    assert_nil session_c.question_responses.find_by(question: question_c)
  end

  test "session that auto-completed via inheritance demotes when source si is removed (NC-2)" do
    # Force session_b to have exactly one active question so inheritance can complete it.
    @session_b.age_band_questionnaire.questions.where.not(id: @question_b.id).update_all(active: false)

    response_a = QuestionResponse.create!(questionnaire_session: @session_a, question: @question_a, answer: :si)
    assert @session_b.reload.completed?, "session_b should auto-complete via inherited si"

    response_a.update!(answer: :no)

    assert @session_b.reload.in_progress?, "session_b must demote after inherited row destroyed"
    assert_nil @session_b.completed_at
  end
end
