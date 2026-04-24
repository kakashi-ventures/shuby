# frozen_string_literal: true

module MeasurementsHelper
  # Display the measurement in the current user's preferred unit system.
  # Falls back to metric when no user is signed in (e.g. system tests, mailers).
  def measurement_display(measurement)
    measurement.display_value(unit_system: current_unit_system)
  end

  def measurement_formatted_value(measurement)
    measurement.formatted_value(unit_system: current_unit_system)
  end

  def measurement_unit_label(measurement)
    measurement.unit(unit_system: current_unit_system)
  end

  # For empty-state cards with no Measurement record yet — pick the unit
  # label from the type alone, respecting the user's pref.
  def measurement_unit_label_for_type(type)
    if current_unit_system == "imperial"
      Measurement::IMPERIAL.fetch(type.to_s)[:label]
    else
      t("measurements.units.#{type}")
    end
  end

  # Data hash for links that open the measurement overlay. Shared by
  # dashboard, card_metric, and the empty-state grid so all three routes
  # through the same Stimulus action.
  def measurement_overlay_link_data(_type)
    {
      turbo_frame: "measurement_form",
      action: "click->measurement-overlay#openWithFrame"
    }
  end

  private

  def current_unit_system
    current_user&.measurement_unit || User::MeasurementUnit::DEFAULT
  end
end
