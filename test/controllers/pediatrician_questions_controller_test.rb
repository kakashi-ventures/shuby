# frozen_string_literal: true

require "test_helper"

class PediatricianQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:company)
    @child = children(:sophia)
    @question = pediatrician_questions(:sophia_question_one)
    sign_in @user
    switch_account(@account)
  end

  # === Create ===

  test "should create question" do
    assert_difference("PediatricianQuestion.count", 1) do
      post child_pediatrician_questions_path(@child), params: {
        pediatrician_question: {body: "Nuova domanda per il pediatra"}
      }
    end
    assert_response :redirect
  end

  test "should create question via turbo stream" do
    assert_difference("PediatricianQuestion.count", 1) do
      post child_pediatrician_questions_path(@child), params: {
        pediatrician_question: {body: "Nuova domanda via turbo"}
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create fails with blank body" do
    assert_no_difference("PediatricianQuestion.count") do
      post child_pediatrician_questions_path(@child), params: {
        pediatrician_question: {body: ""}
      }
    end
  end

  # === Destroy ===

  test "should destroy question" do
    assert_difference("PediatricianQuestion.count", -1) do
      delete child_pediatrician_question_path(@child, @question)
    end
    assert_response :redirect
  end

  test "should destroy question via turbo stream" do
    assert_difference("PediatricianQuestion.count", -1) do
      delete child_pediatrician_question_path(@child, @question), as: :turbo_stream
    end
    assert_response :success
  end

  # === Authentication ===

  test "requires authentication for create" do
    sign_out @user
    assert_no_difference("PediatricianQuestion.count") do
      post child_pediatrician_questions_path(@child), params: {
        pediatrician_question: {body: "Test"}
      }
    end
    assert_response :redirect
  end

  test "requires authentication for destroy" do
    sign_out @user
    assert_no_difference("PediatricianQuestion.count") do
      delete child_pediatrician_question_path(@child, @question)
    end
    assert_response :redirect
  end

  # === Authorization / Multi-tenancy ===

  test "cannot create question for child in another account" do
    sign_out @user
    sign_in users(:two)
    switch_account(accounts(:two))

    assert_no_difference("PediatricianQuestion.count") do
      post child_pediatrician_questions_path(@child), params: {
        pediatrician_question: {body: "Test"}
      }
    end
    assert_response :not_found
  end
end
