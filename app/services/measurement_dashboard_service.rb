# frozen_string_literal: true

class MeasurementDashboardService
  MAX_BOXES = 2
  PRIORITY_TYPES = %w[weight height head_circumference].freeze

  # Staleness thresholds by child age in months
  STALENESS_DAYS = {
    0..3 => 14,
    4..12 => 30,
    13..24 => 60,
    25..36 => 90
  }.freeze

  def self.call(child)
    new(child).call
  end

  def initialize(child)
    @child = child
    @age_months = child.age_in_months
  end

  def call
    boxes = []

    PRIORITY_TYPES.each do |type|
      break if boxes.size >= MAX_BOXES

      measurement = @child.latest_measurement(type)
      state = determine_state(measurement)

      boxes << {
        type: type,
        state: state,
        last_measurement: measurement
      }
    end

    boxes
  end

  private

  def determine_state(measurement)
    return :start_tracking if measurement.nil?
    return :update if stale?(measurement)
    :track
  end

  def stale?(measurement)
    max_days = STALENESS_DAYS.find { |range, _| range.cover?(@age_months) }&.last || 90
    measurement.measured_at < max_days.days.ago
  end
end
