# frozen_string_literal: true

class MeasurementDashboardService
  MeasurementBox = Data.define(:type, :state, :last_measurement)

  MAX_BOXES = 2
  PRIORITY_TYPES = %w[weight height head_circumference].freeze
  ALL_TYPES = %w[weight height head_circumference feeding_weight].freeze

  def self.call(child)
    new(child).call
  end

  # All four type boxes for the type-picker overlay (Figma 463:5785 / 463:5995).
  # Reuses `determine_state` — no MAX_BOXES cap, includes feeding_weight.
  def self.picker_boxes(child)
    builder = new(child)
    ALL_TYPES.map do |type|
      measurement = child.latest_measurement(type)
      MeasurementBox.new(
        type: type,
        state: builder.send(:determine_state, measurement),
        last_measurement: measurement
      )
    end
  end

  def initialize(child)
    @child = child
    @age_months = child.questionnaire_age_in_months
  end

  def call
    boxes = []

    PRIORITY_TYPES.each do |type|
      break if boxes.size >= MAX_BOXES

      measurement = @child.latest_measurement(type)
      state = determine_state(measurement)

      boxes << MeasurementBox.new(type: type, state: state, last_measurement: measurement)
    end

    boxes
  end

  private

  def determine_state(measurement)
    return :start_tracking if measurement.nil?
    return :update if measurement.stale?(@age_months)
    :track
  end
end
