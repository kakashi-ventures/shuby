# frozen_string_literal: true

require "test_helper"

class BetaFeedbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    @user.update_column(:beta_tester, true)
    sign_in @user
    switch_account(@account)
  end

  # === Create ===

  test "beta tester can create feedback" do
    assert_difference("BetaFeedback.count", 1) do
      post beta_feedbacks_path, params: {
        beta_feedback: {
          feedback_type: "bug",
          description: "Il pulsante non risponde al tap sulla dashboard",
          severity: "medium",
          page_url: "/today",
          section: "dashboard"
        }
      }
    end
    assert_response :redirect

    feedback = BetaFeedback.last
    assert_equal @user, feedback.user
    assert_equal @account, feedback.account
    assert_equal "bug", feedback.feedback_type
    assert_equal "dashboard", feedback.section
  end

  test "create with turbo stream returns toast" do
    post beta_feedbacks_path, params: {
      beta_feedback: {
        feedback_type: "suggestion",
        description: "Sarebbe utile avere un filtro per data",
        severity: "low",
        page_url: "/archive",
        section: "archive"
      }
    }, headers: {"Accept" => "text/vnd.turbo-stream.html"}

    assert_response :success
    assert_includes response.body, "turbo-stream"
  end

  test "create falls back to section_from_path when section is blank" do
    post beta_feedbacks_path, params: {
      beta_feedback: {
        feedback_type: "bug",
        description: "Problema generico sulla pagina archivio",
        severity: "low",
        page_url: "/archive/articles",
        section: ""
      }
    }

    feedback = BetaFeedback.last
    assert_equal "archive", feedback.section
  end

  test "create fails with invalid data" do
    assert_no_difference("BetaFeedback.count") do
      post beta_feedbacks_path, params: {
        beta_feedback: {
          feedback_type: "bug",
          description: "Corto",
          page_url: "/today",
          section: "dashboard"
        }
      }, headers: {"Accept" => "text/vnd.turbo-stream.html"}
    end
    assert_response :unprocessable_entity
  end

  # === Authorization ===

  test "non-beta tester gets forbidden" do
    @user.update_column(:beta_tester, false)

    post beta_feedbacks_path, params: {
      beta_feedback: {
        feedback_type: "bug",
        description: "Questo non dovrebbe funzionare per utenti normali",
        page_url: "/today",
        section: "dashboard"
      }
    }
    assert_response :forbidden
  end

  test "unauthenticated user gets redirected" do
    sign_out @user

    post beta_feedbacks_path, params: {
      beta_feedback: {
        feedback_type: "bug",
        description: "Utente non autenticato non puo inviare",
        page_url: "/today",
        section: "dashboard"
      }
    }
    assert_response :redirect
  end
end
