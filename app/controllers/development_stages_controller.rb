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

    # Create new session
    @session = @child.start_new_session(@questionnaire)

    redirect_to stories_child_questionnaire_session_path(@child, @session)
  end

  private

  def set_timeline_bands
    @child_age_months = @child.questionnaire_age_in_months
    @age_bands = Timeline::AgeBands::ALL
    @current_band = Timeline::AgeBands.for_child_age(@child_age_months)
    @current_band_questionnaire = AgeBandQuestionnaire.for_age([@child_age_months, 36].min).first
    @selected_band = if params[:band].present?
      Timeline::AgeBands.find_by_key(params[:band]) || @current_band
    else
      @current_band
    end
  end

  def load_timeline_content
    age = @selected_band[:age_months]
    @growth_phase = GrowthPhase.for_age(age)
    @who_ranges = load_who_ranges(age)
    @development_areas = load_development_areas(age)
  end

  def load_who_ranges(age_months)
    sex = @child.sex&.to_sym
    WhoGrowthStandard.reference_ranges(sex: sex, age_months: age_months)
  end

  def load_development_areas(age_months)
    relationship = timeline_age_relationship(age_months)
    DevelopmentArea.ordered.includes(:age_band_questionnaires).map do |area|
      questionnaire = area.questionnaire_for_age(age_months)
      session = find_timeline_session(questionnaire, relationship)

      {
        area: area,
        questionnaire: questionnaire,
        session: session,
        age_relationship: relationship
      }
    end
  end

  def find_timeline_session(questionnaire, relationship)
    return nil unless questionnaire

    if relationship == :current
      @child.session_for(questionnaire) ||
        @child.questionnaire_sessions
          .where(age_band_questionnaire: questionnaire)
          .completed.recent_first.first
    else
      @child.questionnaire_sessions
        .where(age_band_questionnaire: questionnaire)
        .completed.recent_first.first
    end
  end

  def timeline_age_relationship(band_age)
    return :current unless @current_band_questionnaire

    selected_q = AgeBandQuestionnaire.for_age(band_age.clamp(0, 36)).first
    return :current unless selected_q

    if selected_q.min_age_months < @current_band_questionnaire.min_age_months
      :past
    elsif selected_q.min_age_months == @current_band_questionnaire.min_age_months
      :current
    else
      :future
    end
  end
end
