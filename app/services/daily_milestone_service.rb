# frozen_string_literal: true

# Service for selecting today's development milestone for a child
# Provides deterministic daily rotation through uncompleted milestones
class DailyMilestoneService
  def self.call(child, date: Date.current)
    new(child, date).call
  end

  def initialize(child, date)
    @child = child
    @date = date
  end

  def call
    {
      milestone: todays_milestone,
      state: determine_state
    }
  end

  def todays_milestone
    return nil if uncompleted_questionnaires.empty?

    # Deterministic: same milestone all day, rotates daily
    seed = @child.id + day_number
    index = seed % uncompleted_questionnaires.count
    uncompleted_questionnaires.offset(index).first
  end

  def completed_today?(questionnaire)
    @child.questionnaire_sessions
          .completed
          .where(age_band_questionnaire: questionnaire)
          .where("DATE(completed_at) = ?", @date)
          .exists?
  end

  private

  def determine_state
    if uncompleted_questionnaires.empty?
      :all_complete
    elsif last_completed_today?
      :completed_today
    else
      :proposed
    end
  end

  def last_completed_today?
    @child.questionnaire_sessions
          .completed
          .joins(:age_band_questionnaire)
          .where(age_band_questionnaire: current_age_questionnaires)
          .where("DATE(questionnaire_sessions.completed_at) = ?", @date)
          .exists?
  end

  def uncompleted_questionnaires
    @uncompleted ||= begin
      completed_ids = @child.questionnaire_sessions
                            .completed
                            .where(age_band_questionnaire: current_age_questionnaires)
                            .pluck(:age_band_questionnaire_id)
      current_age_questionnaires.where.not(id: completed_ids)
    end
  end

  def current_age_questionnaires
    @current_age_questionnaires ||= AgeBandQuestionnaire
      .for_age(@child.questionnaire_age_in_months)
      .includes(:development_area)
      .order("development_areas.position")
  end

  def day_number
    @date.to_time.to_i / 86400
  end
end
