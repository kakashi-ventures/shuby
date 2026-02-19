# frozen_string_literal: true

module Child::QuestionnaireManagement
  extend ActiveSupport::Concern

  def session_for(questionnaire)
    questionnaire_sessions
      .where(age_band_questionnaire: questionnaire)
      .where(status: [:not_started, :in_progress])
      .order(created_at: :desc)
      .first
  end

  def start_new_session(questionnaire)
    questionnaire_sessions.create!(
      age_band_questionnaire: questionnaire,
      status: :not_started
    )
  end

  def active_questionnaire_session
    band = current_age_band
    questionnaire_sessions
      .joins(:age_band_questionnaire)
      .where(age_band_questionnaires: {min_age_months: band[:min]})
      .where(status: :in_progress)
      .first
  end

  def completed_sessions_for_area(area)
    questionnaire_sessions.completed.for_area(area).recent_first
  end

  def area_progress(area)
    questionnaire = area.questionnaire_for_age(questionnaire_age_in_months)
    return {completed: false, percentage: 0} unless questionnaire

    session = questionnaire_sessions
      .where(age_band_questionnaire: questionnaire)
      .completed
      .recent_first
      .first

    return {completed: false, percentage: 0} unless session

    {
      completed: true,
      percentage: session.progress_percentage,
      yes_rate: (session.questions_count > 0) ? ((session.yes_count.to_f / session.questions_count) * 100).round : 0,
      needs_attention: session.needs_attention?,
      completed_at: session.completed_at
    }
  end
end
