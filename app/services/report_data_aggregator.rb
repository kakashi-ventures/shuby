# frozen_string_literal: true

class ReportDataAggregator
  def self.call(child)
    new(child).call
  end

  def initialize(child)
    @child = child
    @health_profile = child.health_profile
    @family_profile = child.account.family_profile
  end

  def call
    {
      header: header_data,
      general_info: general_info_data,
      measurements: measurements_data,
      development: development_data,
      questionnaires: questionnaires_data,
      pediatrician_questions: @child.pediatrician_questions.ordered.pluck(:body),
      notes: @child.notes
    }
  end

  private

  def header_data
    {
      child_name: @child.display_name,
      birth_date: @child.birth_date,
      current_age: @child.age_display,
      corrected_age: @child.using_corrected_age? ? corrected_age_display : nil,
      premature: @child.premature?,
      sex: @child.sex,
      generated_at: Time.current
    }
  end

  def general_info_data
    data = {}

    if @health_profile
      data[:birth_weight] = @health_profile.birth_weight_grams
      data[:gestational_age] = gestational_age_text
      data[:birth_complications] = @health_profile.birth_complications_list
      data[:feeding] = @health_profile.current_feeding_type
      data[:sleep_hours] = @health_profile.average_sleep_hours
      data[:floor_play_minutes] = @health_profile.floor_play_minutes_per_day
      data[:hearing_screening] = @health_profile.hearing_screening_result
      data[:vision_screening] = @health_profile.vision_screening_result
    end

    if @family_profile
      data[:family_structure] = @family_profile.family_structure
      data[:number_of_children] = @family_profile.number_of_children
      data[:languages] = @family_profile.languages_spoken_at_home
      data[:hereditary_conditions] = @family_profile.hereditary_conditions_list
    end

    data
  end

  def measurements_data
    recent = @child.measurements
      .where.not(measurement_type: :feeding_weight)
      .ordered
      .limit(20)

    latest = @child.measurements.latest_per_type
      .reject(&:feeding_weight?)

    alerts = latest.select { |m| m.percentile && (m.percentile < 3 || m.percentile > 97) }

    {
      recent: recent.map { |m| measurement_row(m) },
      latest: latest.map { |m| measurement_row(m) },
      alerts: alerts.map { |m| alert_row(m) }
    }
  end

  def development_data
    DevelopmentArea.ordered.map do |area|
      progress = @child.area_progress(area)
      {
        area_name: area.name,
        completed: progress[:completed],
        percentage: progress[:percentage],
        yes_rate: progress[:yes_rate] || 0,
        needs_attention: progress[:needs_attention] || false
      }
    end
  end

  def questionnaires_data
    @child.questionnaire_sessions.completed.recent_first.includes(:age_band_questionnaire).map do |session|
      {
        area_name: session.development_area.name,
        age_band: session.age_band_questionnaire.age_band_label,
        completed_at: session.completed_at,
        yes_count: session.yes_count,
        no_count: session.no_count,
        unknown_count: session.unknown_count,
        needs_attention: session.needs_attention?
      }
    end
  end

  # Pediatrician PDF intentionally renders metric regardless of the user's
  # in-app unit_system preference. Italian pediatric medicine uses SI units;
  # rendering imperial would force the clinician to convert back.
  def measurement_row(m)
    {
      type: m.measurement_type,
      display_value: m.display_value(unit_system: "metric"),
      percentile: m.percentile,
      measured_at: m.measured_at,
      photo: m.photo.attached? ? m.photo : nil
    }
  end

  def alert_row(m)
    alert_key = (m.percentile < 3) ? :alert_low : :alert_high
    {
      type: m.measurement_type,
      percentile: m.percentile,
      alert: I18n.t("pediatrician_report.measurements.#{alert_key}")
    }
  end

  def corrected_age_display
    months = @child.corrected_age_in_months
    I18n.t("children.age.months", count: months)
  end

  def gestational_age_text
    return nil unless @child.gestational_weeks.present?
    I18n.t("pediatrician_report.general_info.weeks_and_days",
      weeks: @child.gestational_weeks,
      days: @child.gestational_days || 0)
  end
end
