# frozen_string_literal: true

module Child::AgeCalculations
  extend ActiveSupport::Concern

  def age_in_months(date = Date.current)
    return 0 unless birth_date
    ((date - birth_date).to_i / 30.44).floor
  end

  def age_display
    months = age_in_months
    if months < 1
      weeks = ((Date.current - birth_date).to_i / 7)
      I18n.t("children.age.weeks", count: weeks)
    elsif months < 24
      I18n.t("children.age.months", count: months)
    else
      years = months / 12
      remaining_months = months % 12
      if remaining_months.zero?
        I18n.t("children.age.years", count: years)
      else
        I18n.t("children.age.years_and_months", years: years, months: remaining_months)
      end
    end
  end

  def detailed_age_display
    return nil unless birth_date

    total_days = (Date.current - birth_date).to_i

    if total_days < 7
      I18n.t("children.age.days", count: total_days)
    elsif age_in_months < 1
      weeks = (total_days / 7)
      I18n.t("children.age.weeks", count: weeks)
    elsif age_in_months < 12
      months = age_in_months
      remaining_days = total_days - (months * 30.44).to_i
      weeks = (remaining_days / 7).floor.clamp(0, 3)

      if weeks == 0
        I18n.t("children.age.months", count: months)
      else
        format_months_and_weeks(months, weeks)
      end
    else
      years = age_in_months / 12
      remaining_months = age_in_months % 12

      if remaining_months.zero?
        I18n.t("children.age.years", count: years)
      else
        I18n.t("children.age.years_and_months", years: years, months: remaining_months)
      end
    end
  end

  def premature?
    gestational_weeks.present? && gestational_weeks < 37
  end

  def corrected_age_in_months(date = Date.current)
    return age_in_months(date) unless premature? && gestational_weeks.present?

    weeks_early = 40 - gestational_weeks
    days_early = (weeks_early * 7) + (7 - (gestational_days || 0))
    corrected_birth_date = birth_date + days_early.days

    ((date - corrected_birth_date).to_i / 30.44).floor
  end

  def questionnaire_age_in_months(date = Date.current)
    if premature? && age_in_months(date) < 24
      corrected_age_in_months(date)
    else
      age_in_months(date)
    end
  end

  def using_corrected_age?
    premature? && age_in_months < 24
  end

  def age_correction_months
    return 0 unless using_corrected_age?
    age_in_months - corrected_age_in_months
  end

  def current_age_band
    months = age_in_months
    effective_month = [months, 36].min
    label = I18n.t("children.age.months", count: effective_month)
    {min: effective_month, max: effective_month + 1, label: label}
  end

  private

  def format_months_and_weeks(months, weeks)
    months_key = (months == 1) ? "1" : "other"
    weeks_key = (weeks == 1) ? "1" : "other"
    I18n.t("children.age.months_and_weeks_#{months_key}_#{weeks_key}", months: months, weeks: weeks)
  end
end
