# frozen_string_literal: true

class DevelopmentStagesController < ApplicationController
  include ChildScoped

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

    past_in_progress = @child.in_progress_past_sessions
      .index_by { |s| s.age_band_questionnaire.development_area_id }
    @area_sessions.each do |area_id, data|
      data[:past_in_progress] = past_in_progress[area_id]
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
    @past_in_progress_session = @child.in_progress_past_sessions.for_area(@area).first
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
end
