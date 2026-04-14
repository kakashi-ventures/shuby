# frozen_string_literal: true

class BetaFeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :require_beta_tester!

  def create
    @feedback = current_account.beta_feedbacks.build(feedback_params)
    @feedback.user = current_user
    @feedback.section = BetaFeedback.section_from_path(@feedback.page_url) if @feedback.section.blank?

    if @feedback.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append("toasts",
            ToastComponent.new(title: "Grazie per il tuo feedback!", dismiss_after: 3000))
        }
        format.html { redirect_back fallback_location: root_path, notice: "Grazie per il tuo feedback!" }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append("toasts",
            ToastComponent.new(title: "Errore nell'invio", description: @feedback.errors.full_messages.join(", "), dismiss_after: 5000)),
            status: :unprocessable_entity
        }
        format.html { redirect_back fallback_location: root_path, alert: "Errore nell'invio del feedback." }
      end
    end
  end

  private

  def require_beta_tester!
    head :forbidden unless current_user.beta_tester?
  end

  def feedback_params
    params.expect(beta_feedback: [:feedback_type, :description, :severity, :page_url, :section, :screenshot, :metadata])
  end
end
