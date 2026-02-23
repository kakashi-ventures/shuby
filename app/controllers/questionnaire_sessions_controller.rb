# frozen_string_literal: true

class QuestionnaireSessionsController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child
  before_action :set_session
  before_action :ensure_editable!, only: [:edit, :update]

  def show
    # Session overview/summary
    @questionnaire = @session.age_band_questionnaire
    @area = @questionnaire.development_area
    @responses = @session.question_responses.includes(:question).order("questions.position")

    # Load warning signs and stimulation activities for this month
    month = @questionnaire.min_age_months
    @warnings = WarningSign.for_month(month)
    @activities = StimulationActivity.for_month(month)
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

  def stories
    @questionnaire = @session.age_band_questionnaire
    @area = @questionnaire.development_area
    @questions = @questionnaire.questions.active.ordered.to_a

    # Check if already completed
    if @session.completed?
      redirect_to child_questionnaire_session_path(@child, @session)
      return
    end

    render layout: "stories"
  end

  def answer
    # Guard: prevent duplicate submissions on completed sessions
    if @session.completed?
      respond_to do |format|
        format.html { redirect_to child_questionnaire_session_path(@child, @session), notice: t(".already_completed") }
        format.json { render json: { success: false, error: t(".already_completed") }, status: :unprocessable_entity }
      end
      return
    end

    @question = Question.find(params[:question_id])
    answer_value = params[:answer]

    response = @session.question_responses.find_or_initialize_by(question: @question)
    response.answer = answer_value
    response.notes = params[:notes] if params[:notes].present?

    if response.save
      # Check if session is complete
      completed = @session.reload.completed?

      respond_to do |format|
        format.html do
          if completed
            redirect_to child_questionnaire_session_path(@child, @session), notice: t(".completed")
          else
            redirect_to continue_child_questionnaire_session_path(@child, @session)
          end
        end
        format.json do
          render json: {
            success: true,
            completed: completed,
            progress: @session.progress_percentage
          }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to continue_child_questionnaire_session_path(@child, @session), alert: t(".error") }
        format.json { render json: { success: false, error: t(".error") }, status: :unprocessable_entity }
      end
    end
  end

  def complete
    @session.complete!
    redirect_to child_development_stage_path(@child, @session.age_band_questionnaire.development_area.slug),
                notice: t(".completed")
  end

  def edit
    @questionnaire = @session.age_band_questionnaire
    @area = @questionnaire.development_area
    @responses = @session.question_responses.includes(:question).order("questions.position")
  end

  def update
    # Update notes for each response
    updated_count = 0
    if params[:responses].present?
      params[:responses].each do |response_id, response_params|
        response = @session.question_responses.find(response_id)
        if response.update(notes: response_params[:notes])
          updated_count += 1
        end
      end
    end

    redirect_to child_questionnaire_session_path(@child, @session),
                notice: t(".success", count: updated_count)
  end

  private

  def set_session
    @session = @child.questionnaire_sessions.find(params[:id])
    authorize @session
  end

  def ensure_editable!
    return if @session.editable?

    redirect_to child_questionnaire_session_path(@child, @session),
      alert: t("questionnaire_sessions.edit.edit_window_expired")
  end
end
