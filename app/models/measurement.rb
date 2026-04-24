# frozen_string_literal: true

class Measurement < ApplicationRecord
  MAX_PHOTO_SIZE = 10.megabytes
  ALLOWED_PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze

  belongs_to :child
  has_one_attached :photo

  enum :measurement_type, {weight: 0, height: 1, head_circumference: 2, feeding_weight: 3}

  validates :measurement_type, presence: true
  validates :value, presence: true, numericality: {greater_than: 0}
  validates :measured_at, presence: true
  validates :percentile, numericality: {in: 0..100}, allow_nil: true
  validate :measured_at_not_in_future
  validate :value_within_range
  validate :photo_content_type
  validate :photo_size

  before_save :calculate_percentile, if: -> { value_changed? || measurement_type_changed? || measured_at_changed? }

  scope :ordered, -> { order(measured_at: :desc) }
  scope :by_type, ->(type) { where(measurement_type: type) }
  scope :latest_per_type, -> {
    select("DISTINCT ON (measurement_type) *")
      .order(:measurement_type, measured_at: :desc)
  }

  # Imperial conversion table keyed by measurement_type.
  # scalar: divide stored SI value by this to get imperial value.
  IMPERIAL = {
    "weight" => {scalar: 453.59237, label: "lb", decimals: 2},
    "feeding_weight" => {scalar: 28.3495, label: "oz", decimals: 2},
    "height" => {scalar: 2.54, label: "in", decimals: 1},
    "head_circumference" => {scalar: 2.54, label: "in", decimals: 1}
  }.freeze

  # Human-readable display value. Pass unit_system: "imperial" to convert.
  def display_value(unit_system: "metric")
    prefix = (measurement_type == "feeding_weight") ? "+" : ""
    "#{prefix}#{formatted_value(unit_system: unit_system)} #{unit(unit_system: unit_system)}"
  end

  # Unit label for display.
  def unit(unit_system: "metric")
    if unit_system == "imperial"
      IMPERIAL[measurement_type][:label]
    else
      case measurement_type
      when "weight", "feeding_weight" then "gr"
      when "height", "head_circumference" then "cm"
      end
    end
  end

  # Formatted value without unit. In imperial mode the stored SI value is
  # converted and rounded to the type's display precision (see IMPERIAL).
  def formatted_value(unit_system: "metric")
    if unit_system == "imperial"
      converted = value / IMPERIAL[measurement_type][:scalar]
      format_decimal(converted.round(IMPERIAL[measurement_type][:decimals]))
    else
      case measurement_type
      when "weight", "feeding_weight" then value.to_i.to_s
      when "height", "head_circumference" then format_decimal(value)
      end
    end
  end

  # Staleness thresholds: max days between measurements by child age (months)
  STALENESS_THRESHOLDS = {
    0..3 => 14,
    4..12 => 30,
    13..24 => 60,
    25..36 => 90
  }.freeze

  def self.staleness_days_for(age_months)
    STALENESS_THRESHOLDS.find { |range, _| range.cover?(age_months) }&.last || 90
  end

  # Check if measurement is stale based on child's age
  def stale?(child_age_months)
    return true unless measured_at
    measured_at < self.class.staleness_days_for(child_age_months).days.ago
  end

  private

  def calculate_percentile
    self.percentile = PercentileCalculator.call(measurement: self, child: child)
  end

  def measured_at_not_in_future
    errors.add(:measured_at, :in_future) if measured_at.present? && measured_at > Time.current
  end

  def value_within_range
    return unless value.present?

    case measurement_type
    when "weight"
      errors.add(:value, :out_of_range) unless value.between?(500, 25_000)
    when "height"
      errors.add(:value, :out_of_range) unless value.between?(30, 120)
    when "head_circumference"
      errors.add(:value, :out_of_range) unless value.between?(20, 60)
    when "feeding_weight"
      errors.add(:value, :out_of_range) unless value.between?(1, 500)
    end
  end

  def photo_content_type
    return unless photo.attached?
    return if ALLOWED_PHOTO_CONTENT_TYPES.include?(photo.blob.content_type)

    errors.add(:photo, :invalid_content_type)
  end

  def photo_size
    return unless photo.attached?
    return if photo.blob.byte_size <= MAX_PHOTO_SIZE

    errors.add(:photo, :too_large, max: ActiveSupport::NumberHelper.number_to_human_size(MAX_PHOTO_SIZE))
  end

  def format_decimal(val)
    (val == val.to_i) ? val.to_i.to_s : val.to_s.sub(".", ",")
  end
end
