# frozen_string_literal: true

class Child < AccountRecord
  belongs_to :account
  has_many :questionnaire_sessions, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_one :health_profile, class_name: "ChildHealthProfile", dependent: :destroy
  has_one_attached :avatar

  accepts_nested_attributes_for :health_profile

  enum :sex, {unspecified: 0, male: 1, female: 2, intersex: 3}

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

  # Detailed age display for dashboard (months + weeks, or years + months)
  def detailed_age_display
    return nil unless birth_date

    total_days = (Date.current - birth_date).to_i

    if total_days < 7
      # Days only for newborns (less than a week)
      I18n.t("children.age.days", count: total_days)
    elsif age_in_months < 1
      # Weeks only (under 1 month)
      weeks = (total_days / 7)
      I18n.t("children.age.weeks", count: weeks)
    elsif age_in_months < 12
      # Months and weeks for first year
      months = age_in_months
      remaining_days = total_days - (months * 30.44).to_i
      weeks = (remaining_days / 7).floor.clamp(0, 3)

      if weeks == 0
        I18n.t("children.age.months", count: months)
      else
        format_months_and_weeks(months, weeks)
      end
    else
      # Years and months for 12+ months
      years = age_in_months / 12
      remaining_months = age_in_months % 12

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

  # Determine which age to use for questionnaire selection
  # Uses corrected age for premature babies under 24 months (clinical standard)
  def questionnaire_age_in_months(date = Date.current)
    if premature? && age_in_months(date) < 24
      corrected_age_in_months(date)
    else
      age_in_months(date)
    end
  end

  # Check if using corrected age for questionnaires
  def using_corrected_age?
    premature? && age_in_months < 24
  end

  # Get age difference for display (how many months early)
  def age_correction_months
    return 0 unless using_corrected_age?
    age_in_months - corrected_age_in_months
  end

  # Get latest measurement of a specific type
  def latest_measurement(type)
    measurements.by_type(type).ordered.first
  end

  # Get latest measurements grouped by type (one per type)
  def latest_measurements
    measurements.latest_per_type
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
      yes_rate: (session.questions_count > 0) ? ((session.yes_count.to_f / session.questions_count) * 100).round : 0,
      needs_attention: session.needs_attention?,
      completed_at: session.completed_at
    }
  end

  # Profile completeness tracking
  def profile_completeness_percentage
    base_fields = [name, birth_date, sex.present? && sex != "unspecified"]
    base_filled = base_fields.count { |f| f.present? && f != false }

    if health_profile.present?
      health_fields = [
        health_profile.birth_weight_grams,
        health_profile.hearing_screening_result,
        health_profile.current_feeding_type
      ]
      health_filled = health_fields.count(&:present?)
      total_fields = base_fields.size + health_fields.size
      total_filled = base_filled + health_filled
    else
      total_fields = base_fields.size + 3 # Expecting 3 health fields
      total_filled = base_filled
    end

    (total_filled.to_f / total_fields * 100).round
  end

  def profile_complete?
    profile_completeness_percentage >= 80
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

  # Helper for months and weeks pluralization
  def format_months_and_weeks(months, weeks)
    months_key = (months == 1) ? "1" : "other"
    weeks_key = (weeks == 1) ? "1" : "other"
    I18n.t("children.age.months_and_weeks_#{months_key}_#{weeks_key}", months: months, weeks: weeks)
  end
end
