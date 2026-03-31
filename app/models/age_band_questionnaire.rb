# frozen_string_literal: true

class AgeBandQuestionnaire < ApplicationRecord
  CLINICAL_BANDS = [
    {min: 0, max: 2, label: "1° Mese", representative_month: 1},
    {min: 2, max: 5, label: "3° Mese", representative_month: 3},
    {min: 5, max: 8, label: "6° Mese", representative_month: 6},
    {min: 8, max: 11, label: "9° Mese", representative_month: 9},
    {min: 11, max: 18, label: "12° Mese", representative_month: 12},
    {min: 18, max: 36, label: "18-24° Mesi", representative_month: 18},
    {min: 36, max: 37, label: "36° Mese", representative_month: 36}
  ].freeze

  belongs_to :development_area
  has_many :questions, -> { active.order(:position) }, dependent: :destroy
  has_many :questionnaire_sessions, dependent: :destroy

  validates :min_age_months, presence: true,
    numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 36}
  validates :max_age_months, presence: true,
    numericality: {greater_than: 0, less_than_or_equal_to: 37}
  validate :max_greater_than_min
  validates :development_area_id, uniqueness: {scope: :min_age_months}
  validates :version, presence: true, numericality: {only_integer: true, greater_than: 0}

  scope :ordered, -> { order(:min_age_months) }
  scope :for_age, ->(months) { where("min_age_months <= ? AND max_age_months > ?", months, months) }
  scope :current_version, -> { order(version: :desc).limit(1) }

  def active_questions
    questions.active.ordered
  end

  def age_band_label
    band = CLINICAL_BANDS.find { |b| b[:min] == min_age_months && b[:max] == max_age_months }
    band ? band[:label] : I18n.t("age_bands.range", min: min_age_months, max: max_age_months)
  end

  def display_title
    title.presence || "#{development_area.name} (#{age_band_label})"
  end

  # Increment version when questions change significantly
  # @return [Boolean] true if successfully bumped
  def bump_version!
    update!(version: version + 1)
  end

  # Check if this is the current version
  # @return [Boolean] true if this is the latest version
  def current_version?
    self.class.where(development_area: development_area, min_age_months: min_age_months)
      .maximum(:version) == version
  end

  private

  def max_greater_than_min
    return unless min_age_months && max_age_months
    errors.add(:max_age_months, :must_be_greater) if max_age_months <= min_age_months
  end
end
