# frozen_string_literal: true

class QuestionnaireSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child
  before_action :set_session

  def show
    # Session overview/summary
    @questionnaire = @session.age_band_questionnaire
    @area = @questionnaire.development_area
    @responses = @session.question_responses.includes(:question).order("questions.position")
  end

  def continue
    @questionnaire = @session.age_band_questionnaire
    @area = @questionnaire.development_area
    @question = @session.next_unanswered_question

    if @question.nil?
      # All questions answered, mark complete
      @session.complete! unless @session.completed?
      redirect_to child_questionnaire_session_path(@child, @session)
      return
    end

    @current_index = @session.answered_count + 1
    @total = @session.questions_count
  end

  def answer
    @question = Question.find(params[:question_id])
    answer_value = params[:answer]

    response = @session.question_responses.find_or_initialize_by(question: @question)
    response.answer = answer_value
    response.notes = params[:notes] if params[:notes].present?

    if response.save
      # Check if session is complete
      if @session.reload.completed?
        redirect_to child_questionnaire_session_path(@child, @session),
                    notice: t(".completed")
      else
        redirect_to continue_child_questionnaire_session_path(@child, @session)
      end
    else
      redirect_to continue_child_questionnaire_session_path(@child, @session),
                  alert: t(".error")
    end
  end

  def complete
    @session.complete!
    redirect_to child_development_stage_path(@child, @session.age_band_questionnaire.development_area.slug),
                notice: t(".completed")
  end

  private

  def set_child
    @child = policy_scope(Child).find(params[:child_id])
    authorize @child, :show?
  end

  def set_session
    @session = @child.questionnaire_sessions.find(params[:id])
    authorize @session
  end
end
