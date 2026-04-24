# frozen_string_literal: true

module User::MeasurementUnit
  extend ActiveSupport::Concern

  UNITS = %w[metric imperial].freeze
  DEFAULT = "metric"

  included do
    store_accessor :preferences, :measurement_unit
    validates :measurement_unit, inclusion: {in: UNITS}, allow_nil: true
  end

  def measurement_unit
    super.presence || DEFAULT
  end

  def metric_units?
    measurement_unit == "metric"
  end

  def imperial_units?
    measurement_unit == "imperial"
  end
end
