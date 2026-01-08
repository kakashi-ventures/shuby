# frozen_string_literal: true

require "test_helper"

class QuestionnaireSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    @in_progress_session = questionnaire_sessions(:in_progress_session)
    @completed_session = questionnaire_sessions(:completed_session)
    sign_in @user
    switch_account(@account)
  end

  test "should show completed session" do
    get child_questionnaire_session_path(@child, @completed_session)
    assert_response :success
  end

  test "should continue in_progress session" do
    get continue_child_questionnaire_session_path(@child, @in_progress_session)
    assert_response :success
  end

  test "should redirect completed session from continue to show" do
    get continue_child_questionnaire_session_path(@child, @completed_session)
    assert_response :redirect
    assert_redirected_to child_questionnaire_session_path(@child, @completed_session)
  end

  test "should answer question" do
    question = @in_progress_session.next_unanswered_question
    skip "No unanswered questions available" if question.nil?

    assert_difference -> { @in_progress_session.question_responses.count }, 1 do
      post answer_child_questionnaire_session_path(@child, @in_progress_session),
        params: { question_id: question.id, answer: "si" }
    end
    assert_response :redirect
  end

  test "should complete session" do
    session = questionnaire_sessions(:in_progress_session)
    patch complete_child_questionnaire_session_path(@child, session)
    assert_response :redirect
    session.reload
    assert session.completed?
  end

  test "requires authentication" do
    sign_out @user
    get child_questionnaire_session_path(@child, @completed_session)
    assert_response :redirect
  end

  test "cannot access non-existent child session" do
    # Test that attempting to access a non-existent child returns an error
    fake_child_id = 999999
    fake_session_id = 999999
    get child_questionnaire_session_path(fake_child_id, fake_session_id)

    # Should return 404 Not Found or redirect if error handling is in place
    assert_includes [404, 302], response.status
  end
end
