# frozen_string_literal: true

class MeasurementDashboardService
  MeasurementBox = Data.define(:type, :state, :last_measurement)

  MAX_BOXES = 2
  PRIORITY_TYPES = %w[weight height head_circumference].freeze

  def self.call(child)
    new(child).call
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
