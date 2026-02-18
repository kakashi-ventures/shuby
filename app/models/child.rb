# frozen_string_literal: true

class Child < AccountRecord
  include AgeCalculations
  include QuestionnaireManagement
  include ProfileCompleteness

  belongs_to :account
  has_many :questionnaire_sessions, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_one :health_profile, class_name: "ChildHealthProfile", dependent: :destroy
  has_many :pediatrician_questions, dependent: :destroy
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

  def display_name
    name.presence || nickname
  end

  def latest_measurement(type)
    measurements.by_type(type).ordered.first
  end

  def latest_measurements
    measurements.latest_per_type
  end

  private

  def completeness_fields
    base = [name, birth_date, sex.present? && sex != "unspecified"]
    health = if health_profile.present?
      [
        health_profile.birth_weight_grams,
        health_profile.hearing_screening_result,
        health_profile.current_feeding_type
      ]
    else
      [nil, nil, nil]
    end
    base + health
  end

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
