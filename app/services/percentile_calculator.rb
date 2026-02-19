# frozen_string_literal: true

# Computes WHO percentile for a child measurement using the LMS Box-Cox method.
#
# Usage:
#   PercentileCalculator.call(measurement: m, child: c) # => Integer 0-100 or nil
class PercentileCalculator
  def self.call(measurement:, child:)
    new(measurement:, child:).call
  end

  def initialize(measurement:, child:)
    @measurement = measurement
    @child = child
  end

  def call
    return nil unless calculable?

    lms = WhoGrowthStandard.lms_for(sex: sex, type: type, age_months: age_in_months)
    return nil unless lms

    z = z_score(normalized_value, lms)
    z_to_percentile(z)
  end

  private

  def calculable?
    return false if @measurement.feeding_weight?
    return false unless @child.sex.in?(%w[male female])
    return false unless @child.birth_date
    return false unless @measurement.measured_at
    true
  end

  def sex
    @child.sex.to_sym
  end

  def type
    @measurement.measurement_type.to_sym
  end

  # Use corrected age for premature babies under 24 months
  def age_in_months
    date = @measurement.measured_at.to_date
    if @child.premature? && @child.age_in_months(date) < 24
      @child.corrected_age_in_months(date)
    else
      @child.age_in_months(date)
    end
  end

  # Convert to WHO units (weight: grams → kg)
  def normalized_value
    if @measurement.weight?
      @measurement.value / 1000.0
    else
      @measurement.value.to_f
    end
  end

  # LMS Box-Cox transformation to z-score
  def z_score(value, lms)
    l, m, s = lms.values_at(:l, :m, :s)
    if l.zero?
      Math.log(value / m) / s
    else
      (((value / m)**l) - 1) / (l * s)
    end
  end

  # Standard normal CDF via Math.erf (Gauss error function)
  def z_to_percentile(z)
    percentile = (0.5 * (1.0 + Math.erf(z / Math.sqrt(2)))) * 100
    percentile.round.clamp(0, 100)
  end
end
