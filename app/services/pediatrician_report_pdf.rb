# frozen_string_literal: true

class PediatricianReportPdf
  COLORS = {
    primary: "1E3A5F",
    alert: "EF4444",
    muted: "666666",
    light_bg: "F3F4F6",
    white: "FFFFFF",
    black: "000000",
    attention: "F59E0B"
  }.freeze

  FONTS_DIR = Rails.root.join("app", "assets", "fonts")
  Prawn::Fonts::AFM.hide_m17n_warning = true

  def self.call(data)
    new(data).render
  end

  def initialize(data)
    @data = data
  end

  def render
    pdf = Prawn::Document.new(
      page_size: "A4",
      margin: [40, 40, 60, 40],
      info: {Title: t("title"), Author: "Shuby", Creator: "Shuby App"}
    )

    register_fonts(pdf)
    render_header(pdf)
    render_general_info(pdf)
    render_measurements(pdf)
    render_development(pdf)
    render_questionnaires(pdf)
    render_questions(pdf)
    render_notes(pdf)
    render_footer(pdf)

    pdf.render
  end

  private

  def t(key, **)
    I18n.t("pediatrician_report.#{key}", **)
  end

  def register_fonts(pdf)
    if FONTS_DIR.exist? && FONTS_DIR.join("Helvetica.ttf").exist?
      pdf.font_families.update("Helvetica" => {
        normal: FONTS_DIR.join("Helvetica.ttf").to_s,
        bold: FONTS_DIR.join("Helvetica-Bold.ttf").to_s
      })
      pdf.font "Helvetica"
    end
  rescue
    # Fall back to Prawn's built-in Helvetica
  end

  def render_header(pdf)
    pdf.fill_color COLORS[:primary]
    pdf.text "SHUBY", size: 24, style: :bold
    pdf.fill_color COLORS[:muted]
    pdf.text t("sections.header"), size: 10
    pdf.move_down 10

    pdf.fill_color COLORS[:black]
    header = @data[:header]

    rows = [
      [t("child_info.name"), header[:child_name]],
      [t("child_info.birth_date"), I18n.l(header[:birth_date], format: :long)],
      [t("child_info.current_age"), header[:current_age]],
      [t("child_info.sex"), sex_label(header[:sex])]
    ]

    if header[:premature]
      rows << [t("child_info.premature"), I18n.t("common.yes", default: "Si")]
    end

    if header[:corrected_age]
      rows << [t("child_info.corrected_age"), header[:corrected_age]]
    end

    rows << [t("generated_at", date: ""), I18n.l(header[:generated_at], format: :long)]

    info_table(pdf, rows)
    pdf.move_down 15
  end

  def render_general_info(pdf)
    info = @data[:general_info]
    return if info.empty?

    section_heading(pdf, t("sections.general_info"))

    rows = []
    rows << [t("general_info.birth_weight"), "#{info[:birth_weight]} gr"] if info[:birth_weight]
    rows << [t("general_info.gestational_age"), info[:gestational_age]] if info[:gestational_age]

    if info[:birth_complications]&.any?
      rows << [t("general_info.birth_complications"), info[:birth_complications].join(", ")]
    end

    rows << [t("general_info.feeding"), feeding_label(info[:feeding])] if info[:feeding]
    rows << [t("general_info.sleep"), t("general_info.sleep_hours", hours: info[:sleep_hours])] if info[:sleep_hours]
    rows << [t("general_info.floor_play"), t("general_info.floor_play_minutes", minutes: info[:floor_play_minutes])] if info[:floor_play_minutes]
    rows << [t("general_info.screening.hearing"), hearing_label(info[:hearing_screening])] if info[:hearing_screening]
    rows << [t("general_info.screening.vision"), vision_label(info[:vision_screening])] if info[:vision_screening]

    # Family context
    rows << [t("general_info.family_structure"), family_structure_label(info[:family_structure])] if info[:family_structure]
    rows << [t("general_info.number_of_children"), info[:number_of_children].to_s] if info[:number_of_children]
    rows << [t("general_info.languages"), info[:languages].to_s] if info[:languages]

    if info[:hereditary_conditions]&.any?
      rows << [t("general_info.hereditary_conditions"), hereditary_labels(info[:hereditary_conditions])]
    end

    info_table(pdf, rows) if rows.any?
    pdf.move_down 15
  end

  def render_measurements(pdf)
    section_heading(pdf, t("sections.measurements"))
    measurements = @data[:measurements]

    if measurements[:recent].empty?
      pdf.fill_color COLORS[:muted]
      pdf.text t("measurements.no_data"), size: 10, style: :italic
      pdf.fill_color COLORS[:black]
      pdf.move_down 15
      return
    end

    # Alerts banner
    if measurements[:alerts].any?
      pdf.fill_color COLORS[:alert]
      measurements[:alerts].each do |alert|
        pdf.text "#{alert[:alert]} — #{measurement_type_label(alert[:type])} (P#{alert[:percentile]})",
          size: 9, style: :bold
      end
      pdf.fill_color COLORS[:black]
      pdf.move_down 5
    end

    # Recent measurements table
    header_row = [
      t("measurements.type"),
      t("measurements.value"),
      t("measurements.percentile"),
      t("measurements.date"),
      t("measurements.photo")
    ]

    data_rows = measurements[:recent].map do |m|
      percentile_text = m[:percentile] ? "P#{m[:percentile]}" : "-"
      date_text = m[:measured_at] ? I18n.l(m[:measured_at].to_date, format: :short) : "-"
      [measurement_type_label(m[:type]), m[:display_value], percentile_text, date_text, photo_cell(m[:photo])]
    end

    styled_table(pdf, [header_row] + data_rows)
    pdf.move_down 15
  end

  def photo_cell(photo)
    return "" if photo.nil?

    variant = photo.variant(resize_to_limit: [120, 120], format: "jpg", saver: {quality: 85}).processed
    {image: StringIO.new(variant.download), fit: [50, 50], position: :center}
  rescue StandardError, LoadError => e
    Rails.logger.warn("[PediatricianReportPdf] Failed to embed measurement photo: #{e.class} #{e.message}")
    ""
  end

  def render_development(pdf)
    section_heading(pdf, t("sections.development"))
    dev = @data[:development]

    if dev.all? { |d| !d[:completed] }
      pdf.fill_color COLORS[:muted]
      pdf.text t("development.no_data"), size: 10, style: :italic
      pdf.fill_color COLORS[:black]
      pdf.move_down 15
      return
    end

    header_row = [
      t("development.area"),
      t("development.status"),
      t("development.yes_rate")
    ]

    data_rows = dev.map do |d|
      status = if d[:completed]
        d[:needs_attention] ? t("development.needs_attention") : t("development.completed")
      else
        t("development.not_completed")
      end

      yes_text = d[:completed] ? "#{d[:yes_rate]}%" : "-"
      [d[:area_name], status, yes_text]
    end

    styled_table(pdf, [header_row] + data_rows) do |table|
      data_rows.each_with_index do |_row, i|
        if dev[i][:needs_attention]
          table.row(i + 1).text_color = COLORS[:alert]
        end
      end
    end

    pdf.move_down 15
  end

  def render_questionnaires(pdf)
    section_heading(pdf, t("sections.questionnaires"))
    sessions = @data[:questionnaires]

    if sessions.empty?
      pdf.fill_color COLORS[:muted]
      pdf.text t("questionnaires.no_data"), size: 10, style: :italic
      pdf.fill_color COLORS[:black]
      pdf.move_down 15
      return
    end

    header_row = [
      t("development.area"),
      t("questionnaires.age_band"),
      t("questionnaires.completed_at"),
      t("questionnaires.yes_count"),
      t("questionnaires.no_count"),
      t("questionnaires.unknown_count")
    ]

    data_rows = sessions.map do |s|
      completed_text = s[:completed_at] ? I18n.l(s[:completed_at].to_date, format: :short) : "-"
      [
        s[:area_name],
        s[:age_band],
        completed_text,
        s[:yes_count].to_s,
        s[:no_count].to_s,
        s[:unknown_count].to_s
      ]
    end

    styled_table(pdf, [header_row] + data_rows) do |table|
      sessions.each_with_index do |s, i|
        table.row(i + 1).text_color = COLORS[:alert] if s[:needs_attention]
      end
    end

    pdf.move_down 15
  end

  def render_questions(pdf)
    section_heading(pdf, t("sections.questions"))
    questions = @data[:pediatrician_questions]

    if questions.empty?
      pdf.fill_color COLORS[:muted]
      pdf.text t("questions.no_questions"), size: 10, style: :italic
      pdf.fill_color COLORS[:black]
    else
      questions.each_with_index do |q, i|
        pdf.text "#{i + 1}. #{q}", size: 10
        pdf.move_down 3
      end
    end

    # Ruled lines for visit notes
    pdf.move_down 10
    pdf.fill_color COLORS[:muted]
    pdf.text t("questions.visit_notes"), size: 9, style: :italic
    pdf.fill_color COLORS[:black]
    pdf.move_down 5

    5.times do
      pdf.stroke_color COLORS[:muted]
      pdf.stroke_horizontal_rule
      pdf.move_down 18
    end

    pdf.move_down 5
  end

  def render_notes(pdf)
    notes = @data[:notes]
    return unless notes.present?

    section_heading(pdf, t("sections.notes"))
    pdf.text notes, size: 10
    pdf.move_down 15
  end

  def render_footer(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([0, 30], width: pdf.bounds.width, height: 30) do
        pdf.fill_color COLORS[:muted]
        pdf.text t("footer.disclaimer"), size: 7, align: :center
        pdf.fill_color COLORS[:black]
      end
    end

    pdf.number_pages(
      t("footer.page", current: "<page>", total: "<total>"),
      at: [pdf.bounds.right - 80, -5],
      size: 8,
      color: COLORS[:muted]
    )
  end

  # === Table helpers ===

  def info_table(pdf, rows)
    pdf.table(rows, width: pdf.bounds.width, cell_style: {
      borders: [],
      padding: [4, 8],
      size: 10
    }) do |table|
      table.columns(0).font_style = :bold
      table.columns(0).width = 180
    end
  end

  def styled_table(pdf, rows)
    pdf.table(rows, width: pdf.bounds.width, header: true, cell_style: {
      size: 9,
      padding: [5, 6],
      border_width: 0.5,
      border_color: "DDDDDD"
    }) do |table|
      table.row(0).font_style = :bold
      table.row(0).background_color = COLORS[:primary]
      table.row(0).text_color = COLORS[:white]
      yield table if block_given?
    end
  end

  def section_heading(pdf, text)
    pdf.fill_color COLORS[:primary]
    pdf.text text, size: 13, style: :bold
    pdf.stroke_color COLORS[:primary]
    pdf.stroke_horizontal_rule
    pdf.move_down 8
    pdf.fill_color COLORS[:black]
  end

  # === Label helpers ===

  def sex_label(sex)
    I18n.t("children.sex.#{sex}", default: sex.to_s.humanize)
  end

  def measurement_type_label(type)
    I18n.t("measurements.types.#{type}", default: type.to_s.humanize)
  end

  def feeding_label(type)
    I18n.t("children.health.feeding.#{type}", default: type.to_s.humanize)
  end

  def hearing_label(result)
    I18n.t("children.health.hearing.#{result}", default: result.to_s.humanize)
  end

  def vision_label(result)
    I18n.t("children.health.vision.#{result}", default: result.to_s.humanize)
  end

  def family_structure_label(structure)
    I18n.t("family_profiles.family_structures.#{structure}", default: structure.to_s.humanize)
  end

  def hereditary_labels(conditions)
    conditions.map { |c| I18n.t("family_profiles.hereditary_conditions.#{c}", default: c.humanize) }.join(", ")
  end
end
