# frozen_string_literal: true

# Shared Prawn rendering primitives for the app's PDF export services
# (PediatricianReportPdf, StageReportPdf). Holds the brand palette, font
# registration, and the table/heading helpers so report-specific services
# only describe *what* to render, not *how* to style it.
#
# Include into a Prawn-backed service; all helpers are private instance methods
# that take the Prawn::Document as their first argument.
module PdfStyling
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

  private

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
end
