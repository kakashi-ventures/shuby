# frozen_string_literal: true

class DevelopmentStagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child

  def index
    @areas = DevelopmentArea.ordered.includes(:age_band_questionnaires)
    @child_age = @child.questionnaire_age_in_months
    @current_band = @child.current_age_band

    # Get current/active sessions for each area
    @area_sessions = {}
    @areas.each do |area|
      questionnaire = area.questionnaire_for_age(@child_age)
      next unless questionnaire

      session = @child.session_for(questionnaire) ||
                @child.questionnaire_sessions
                      .where(age_band_questionnaire: questionnaire)
                      .completed
                      .recent_first
                      .first

      @area_sessions[area.id] = {
        questionnaire: questionnaire,
        session: session,
        progress: session&.progress_fraction || "0/#{questionnaire.questions.count}"
      }
    end
  end

  def show
    @area = DevelopmentArea.find_by!(slug: params[:id])
    @questionnaire = @area.questionnaire_for_age(@child.questionnaire_age_in_months)

    unless @questionnaire
      redirect_to child_development_stages_path(@child), alert: t(".no_questionnaire")
      return
    end

    @current_session = @child.session_for(@questionnaire)
    @completed_sessions = @child.completed_sessions_for_area(@area)
  end

  def start
    @area = DevelopmentArea.find_by!(slug: params[:id])
    @questionnaire = @area.questionnaire_for_age(@child.questionnaire_age_in_months)

    unless @questionnaire
      redirect_to child_development_stages_path(@child), alert: t("development_stages.show.no_questionnaire")
      return
    end

    # Create new session
    @session = @child.start_new_session(@questionnaire)

    redirect_to stories_child_questionnaire_session_path(@child, @session)
  end

  private

  def set_child
    @child = policy_scope(Child).find(params[:child_id])
    authorize @child, :show?
  end
end
