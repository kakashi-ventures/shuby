# frozen_string_literal: true

module GrowthChartHelper
  # Build chart data JSON for the Stimulus controller.
  #
  # Data is always emitted in metric (kg / cm) — the Stimulus controller
  # converts to imperial client-side at render time. This keeps unit-toggle
  # interactions snappy on mobile (no network round-trip) and avoids stale
  # cached page snapshots when the user flips units.
  #
  # `unit_system` is included in the payload only as the *initial* display
  # preference for the controller; conversion factors live in JS.
  def growth_chart_data(child:, type:, unit_system: "metric")
    sex = child.sex.to_sym
    measurements = child.measurements.by_type(type).ordered.to_a

    {
      measurements: format_measurements(measurements, type),
      who_curves: WhoGrowthStandard.percentile_curves(sex: sex, type: type.to_sym),
      type: type,
      unit_system: unit_system,
      title: t("measurements.types.#{type}")
    }
  end

  # CSS class for percentile color coding (green/orange/red)
  def percentile_color_class(percentile)
    return "" unless percentile
    case percentile
    when 0..2 then "text-[var(--color-shuby-red-500)]"
    when 3..9 then "text-[var(--color-shuby-orange-500)]"
    when 10..90 then "text-[var(--color-shuby-green-600)]"
    when 91..97 then "text-[var(--color-shuby-orange-500)]"
    else "text-[var(--color-shuby-red-500)]"
    end
  end

  # Italian description for percentile range
  def percentile_explanation(percentile)
    return nil unless percentile
    case percentile
    when 0..2 then t("measurements.chart.percentile_very_low")
    when 3..9 then t("measurements.chart.percentile_low")
    when 10..90 then t("measurements.chart.percentile_normal")
    when 91..97 then t("measurements.chart.percentile_high")
    else t("measurements.chart.percentile_very_high")
    end
  end

  # Stub for future premium gating
  def premium_charts?(_account)
    true
  end

  private

  def format_measurements(measurements, type)
    measurements.filter_map do |m|
      next unless m.child

      {
        age: age_at_measurement(m),
        value: normalize_for_chart(m.value, type),
        percentile: m.percentile,
        date: I18n.l(m.measured_at, format: :short)
      }
    end
  end

  # Stored values are in SI base units: grams (weight) or cm (height/head).
  # The chart works in kg / cm to match WHO curve units. Imperial conversion
  # happens client-side in growth_chart_controller.
  def normalize_for_chart(value, type)
    metric = (type.to_s == "weight") ? (value / 1000.0) : value.to_f
    metric.round(2)
  end

  # Plots a measurement on the chart's X axis at the child's age-on-that-date.
  # For premature babies under 24 chronological months at the measurement
  # date, uses corrected age (via `Child#age_reference_date`) so the dot
  # lines up with the WHO curve at the same age the percentile is computed
  # against. Without this alignment, premature babies' dots appear shifted
  # to the right on the curve relative to their (correctly-calculated)
  # percentile.
  def age_at_measurement(measurement)
    date = measurement.measured_at.to_date
    reference = measurement.child.age_reference_date(date)
    days = (date - reference).to_i
    (days / 30.44).round(2)
  end
end
