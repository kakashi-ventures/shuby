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
        format_years_and_months(years, remaining_months)
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
        format_years_and_months(years, remaining_months)
      end
    end
  end

  def detailed_corrected_age_display
    return detailed_age_display unless using_corrected_age?

    corrected_birth = corrected_birth_date
    total_days = (Date.current - corrected_birth).to_i
    return detailed_age_display if total_days < 0

    corrected_months = corrected_age_in_months

    if total_days < 7
      I18n.t("children.age.days", count: total_days)
    elsif corrected_months < 1
      weeks = (total_days / 7)
      I18n.t("children.age.weeks", count: weeks)
    elsif corrected_months < 12
      remaining_days = total_days - (corrected_months * 30.44).to_i
      weeks = (remaining_days / 7).floor.clamp(0, 3)

      if weeks == 0
        I18n.t("children.age.months", count: corrected_months)
      else
        format_months_and_weeks(corrected_months, weeks)
      end
    else
      years = corrected_months / 12
      remaining_months = corrected_months % 12

      if remaining_months.zero?
        I18n.t("children.age.years", count: years)
      else
        format_years_and_months(years, remaining_months)
      end
    end
  end

  # Age as of a specific date, formatted for measurement history rows.
  # Uses "weeks + days" granularity for babies under ~3 months (matches Figma
  # node 621:10644 — "6 settimane, 2 giorni"), then falls back to the same
  # months+weeks / years+months progression as `detailed_age_display`.
  #
  # Premature babies under 24 months chronological are displayed at corrected
  # age, mirroring `questionnaire_age_in_months` and `PercentileCalculator`
  # (chart plotting). This keeps the history row and the chart consistent.
  def detailed_age_display_at(date)
    return nil unless birth_date && date

    reference_date = (premature? && age_in_months(date) < 24) ? corrected_birth_date : birth_date
    total_days = (date.to_date - reference_date).to_i
    return nil if total_days.negative?

    if total_days < 7
      I18n.t("children.age.days", count: total_days)
    elsif total_days < 91
      weeks = total_days / 7
      remaining_days = total_days - (weeks * 7)
      if remaining_days.zero?
        I18n.t("children.age.weeks", count: weeks)
      else
        format_weeks_and_days(weeks, remaining_days)
      end
    else
      months_at_date = (total_days / 30.44).floor
      if months_at_date < 12
        remaining_days = total_days - (months_at_date * 30.44).to_i
        weeks = (remaining_days / 7).floor.clamp(0, 3)
        weeks.zero? ? I18n.t("children.age.months", count: months_at_date) : format_months_and_weeks(months_at_date, weeks)
      else
        years = months_at_date / 12
        remaining_months = months_at_date % 12
        remaining_months.zero? ? I18n.t("children.age.years", count: years) : format_years_and_months(years, remaining_months)
      end
    end
  end

  def premature?
    gestational_weeks.present? && gestational_weeks < 37
  end

  def corrected_age_in_months(date = Date.current)
    return age_in_months(date) unless premature? && gestational_weeks.present?

    ((date - corrected_birth_date).to_i / 30.44).floor
  end

  def questionnaire_age_in_months(date = Date.current)
    if premature? && age_in_months(date) < 24
      corrected_age_in_months(date)
    else
      age_in_months(date)
    end
  end

  def questionnaire_age_in_weeks(date = Date.current)
    origin = (premature? && age_in_months(date) < 24) ? corrected_birth_date : birth_date
    [((date - origin).to_i / 7).floor + 1, 1].max
  end

  def using_corrected_age?
    premature? && age_in_months < 24
  end

  def age_correction_months
    return 0 unless using_corrected_age?
    age_in_months - corrected_age_in_months
  end

  def current_age_band
    age = [questionnaire_age_in_months, 36].min
    AgeBandQuestionnaire.for_age(age).first
  end

  private

  def corrected_birth_date
    weeks_early = 40 - gestational_weeks
    days_early = (weeks_early * 7) + (7 - (gestational_days || 0))
    birth_date + days_early.days
  end

  def format_months_and_weeks(months, weeks)
    months_key = (months == 1) ? "1" : "other"
    weeks_key = (weeks == 1) ? "1" : "other"
    I18n.t("children.age.months_and_weeks_#{months_key}_#{weeks_key}", months: months, weeks: weeks)
  end

  def format_years_and_months(years, months)
    years_key = (years == 1) ? "1" : "other"
    months_key = (months == 1) ? "1" : "other"
    I18n.t("children.age.years_and_months_#{years_key}_#{months_key}", years: years, months: months)
  end

  def format_weeks_and_days(weeks, days)
    weeks_key = (weeks == 1) ? "1" : "other"
    days_key = (days == 1) ? "1" : "other"
    I18n.t("children.age.weeks_and_days_#{weeks_key}_#{days_key}", weeks: weeks, days: days)
  end
end
