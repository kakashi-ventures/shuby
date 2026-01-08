# frozen_string_literal: true

class Child < AccountRecord
  belongs_to :account
  has_many :questionnaire_sessions, dependent: :destroy

  enum :sex, {unspecified: 0, male: 1, female: 2}

  validates :name, presence: true
  validates :birth_date, presence: true
  validate :birth_date_not_in_future
  validate :gestational_age_validity

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  # Calculate age in months (chronological only for MVP)
  def age_in_months(date = Date.current)
    return 0 unless birth_date
    ((date - birth_date).to_i / 30.44).floor
  end

  # Human-readable age display
  def age_display
    months = age_in_months
    if months < 1
      weeks = ((Date.current - birth_date).to_i / 7)
      I18n.t("children.age.weeks", count: weeks)
    elsif months < 24
      I18n.t("children.age.months", count: months)
    else
      years = months / 12
      remaining_months = months % 12
      if remaining_months.zero?
        I18n.t("children.age.years", count: years)
      else
        I18n.t("children.age.years_and_months", years: years, months: remaining_months)
      end
    end
  end

  # Data stored, logic deferred to post-MVP
  def premature?
    gestational_weeks.present? && gestational_weeks < 37
  end

  # Get existing in-progress session for a questionnaire
  def session_for(questionnaire)
    questionnaire_sessions
      .where(age_band_questionnaire: questionnaire)
      .where(status: [:not_started, :in_progress])
      .order(created_at: :desc)
      .first
  end

  # Start a new questionnaire session
  def start_new_session(questionnaire)
    questionnaire_sessions.create!(
      age_band_questionnaire: questionnaire,
      status: :not_started
    )
  end

  # Get age band info for current age
  def current_age_band
    months = age_in_months
    case months
    when 0...3 then {min: 0, max: 3, label: "0-3 mesi"}
    when 3...6 then {min: 3, max: 6, label: "3-6 mesi"}
    when 6...9 then {min: 6, max: 9, label: "6-9 mesi"}
    when 9...12 then {min: 9, max: 12, label: "9-12 mesi"}
    when 12...18 then {min: 12, max: 18, label: "12-18 mesi"}
    when 18...24 then {min: 18, max: 24, label: "18-24 mesi"}
    when 24...30 then {min: 24, max: 30, label: "24-30 mesi"}
    else {min: 30, max: 36, label: "30-36 mesi"}
    end
  end

  # Find any in-progress session for current age band
  def active_questionnaire_session
    band = current_age_band
    questionnaire_sessions
      .joins(:age_band_questionnaire)
      .where(age_band_questionnaires: {min_age_months: band[:min]})
      .where(status: :in_progress)
      .first
  end

  # Get completed sessions for an area
  def completed_sessions_for_area(area)
    questionnaire_sessions.completed.for_area(area).recent_first
  end

  # Progress calculations for radar chart / reports
  def area_progress(area)
    questionnaire = area.questionnaire_for_age(age_in_months)
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
      yes_rate: session.questions_count > 0 ? ((session.yes_count.to_f / session.questions_count) * 100).round : 0,
      needs_attention: session.needs_attention?,
      completed_at: session.completed_at
    }
  end

  private

  def birth_date_not_in_future
    errors.add(:birth_date, :in_future) if birth_date.present? && birth_date > Date.current
  end

  def gestational_age_validity
    return unless gestational_weeks.present?
    errors.add(:gestational_weeks, :invalid) unless gestational_weeks.between?(22, 42)
    errors.add(:gestational_days, :invalid) if gestational_days.present? && !gestational_days.between?(0, 6)
  end
end
