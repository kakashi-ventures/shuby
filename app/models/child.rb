# frozen_string_literal: true

class Child < AccountRecord
  belongs_to :account
  has_many :questionnaire_sessions, dependent: :destroy
  has_one :health_profile, class_name: "ChildHealthProfile", dependent: :destroy

  accepts_nested_attributes_for :health_profile

  enum :sex, {unspecified: 0, male: 1, female: 2}

  validates :name, presence: true, unless: -> { nickname.present? }
  validates :nickname, presence: true, unless: -> { name.present? }
  validates :birth_date, presence: true
  validate :birth_date_not_in_future
  validate :birth_date_within_app_scope
  validate :gestational_age_validity

  # Normalize text fields to strip whitespace
  normalizes :name, :nickname, :notes, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ") : value }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  # Return name or nickname for display
  def display_name
    name.presence || nickname
  end

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

  # Calculate corrected age for premature babies
  # Corrected age = chronological age - (40 - gestational_weeks)
  def corrected_age_in_months(date = Date.current)
    return age_in_months(date) unless premature? && gestational_weeks.present?

    weeks_early = 40 - gestational_weeks
    days_early = (weeks_early * 7) + (7 - (gestational_days || 0))
    corrected_birth_date = birth_date + days_early.days

    ((date - corrected_birth_date).to_i / 30.44).floor
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

  # Get age band info for current age (monthly structure: 0-28 months)
  def current_age_band
    months = age_in_months
    # Cap at 28 months (last questionnaire)
    effective_month = [months, 28].min
    label = if effective_month == 1
              "#{effective_month} mese"
            else
              "#{effective_month} mesi"
            end
    {min: effective_month, max: effective_month + 1, label: label}
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

  def birth_date_within_app_scope
    return unless birth_date.present?

    age_months = age_in_months
    max_age = 40 # 36 months + 4 month buffer

    if age_months > max_age
      errors.add(:birth_date, :too_old, max_months: max_age)
    end
  end

  def gestational_age_validity
    return unless gestational_weeks.present?
    errors.add(:gestational_weeks, :invalid) unless gestational_weeks.between?(22, 42)
    errors.add(:gestational_days, :invalid) if gestational_days.present? && !gestational_days.between?(0, 6)
  end
end
