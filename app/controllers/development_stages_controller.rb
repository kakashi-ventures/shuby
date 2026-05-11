# frozen_string_literal: true

class DevelopmentStagesController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child
  before_action :set_timeline_bands, only: [:index, :timeline_content]

  def index
    load_timeline_content
  end

  def timeline_content
    load_timeline_content
    render layout: false
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

    # Reuse existing active session, or start a new one
    @session = @child.session_for(@questionnaire) || @child.start_new_session(@questionnaire)

    redirect_to overlay_frame_child_questionnaire_session_path(@child, @session)
  end

  private

  def set_timeline_bands
    @child_age_months = @child.questionnaire_age_in_months
    @child_age_weeks = @child.questionnaire_age_in_weeks
    @milestones_loader = ChildMilestonesLoader.new(@child)
    @age_bands = Timeline::AgeBands::ALL
    @current_band = @milestones_loader.current_band
    @selected_band = if params[:band].present?
      Timeline::AgeBands.find_by_key(params[:band]) || @current_band
    else
      @current_band
    end
  end

  def load_timeline_content
    age = @selected_band[:age_months]
    @timeline_stage = TimelineStageContent.for_band(@selected_band)
    @who_ranges = load_who_ranges(age)
    @development_areas = @milestones_loader.data_for_band(@selected_band)[:development_areas]
  end

  def load_who_ranges(age_months)
    sex = @child.sex&.to_sym
    WhoGrowthStandard.reference_ranges(sex: sex, age_months: age_months)
  end
end
