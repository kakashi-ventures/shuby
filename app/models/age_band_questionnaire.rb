# frozen_string_literal: true

class AgeBandQuestionnaire < ApplicationRecord
  belongs_to :development_area
  has_many :questions, -> { active.order(:position) }, dependent: :destroy
  has_many :questionnaire_sessions, dependent: :destroy

  validates :min_age_months, presence: true,
            numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 36}
  validates :max_age_months, presence: true,
            numericality: {greater_than: 0, less_than_or_equal_to: 37}
  validate :max_greater_than_min
  validates :development_area_id, uniqueness: {scope: :min_age_months}

  scope :ordered, -> { order(:min_age_months) }
  scope :for_age, ->(months) { where("min_age_months <= ? AND max_age_months > ?", months, months) }

  def active_questions
    questions.active.ordered
  end

  def age_band_label
    # For monthly questionnaires (max - min == 1), show single month
    if max_age_months - min_age_months == 1
      I18n.t("age_bands.single_month", count: min_age_months)
    else
      I18n.t("age_bands.range", min: min_age_months, max: max_age_months)
    end
  end

  def display_title
    title.presence || "#{development_area.name} (#{age_band_label})"
  end

  private

  def max_greater_than_min
    return unless min_age_months && max_age_months
    errors.add(:max_age_months, :must_be_greater) if max_age_months <= min_age_months
  end
end
