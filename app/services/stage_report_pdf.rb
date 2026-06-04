# frozen_string_literal: true

# Renders one age band's questionnaire results as a PDF (per-stage export from
# the milestones accordion). Mirrors PediatricianReportPdf and shares the Prawn
# palette + table helpers via PdfStyling. Receives the structure produced by
# StageReportDataAggregator.
class StageReportPdf
  include PdfStyling

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
    render_areas(pdf)
    render_footer(pdf)

    pdf.render
  end

  private

  def t(key, **)
    I18n.t("stage_report.#{key}", **)
  end

  def render_header(pdf)
    header = @data[:header]

    pdf.fill_color COLORS[:primary]
    pdf.text "SHUBY", size: 24, style: :bold
    pdf.fill_color COLORS[:muted]
    pdf.text t("subtitle"), size: 10
    pdf.move_down 10

    pdf.fill_color COLORS[:black]
    info_table(pdf, [
      [t("header.child"), header[:child_name]],
      [t("header.stage"), header[:band_label]],
      [t("header.generated_at"), I18n.l(header[:generated_at], format: :long)]
    ])
    pdf.move_down 15
  end

  def render_areas(pdf)
    @data[:areas].each { |area| render_area(pdf, area) }
  end

  def render_area(pdf, area)
    section_heading(pdf, "#{area[:area_name]} — #{status_label(area[:status])}")

    if area[:status] == :not_available
      muted_note(pdf, t("status_notes.not_available"))
      return
    end

    render_questions_table(pdf, area[:questions]) if area[:questions].any?
    render_summary(pdf, area)
    pdf.move_down 15
  end

  def render_questions_table(pdf, questions)
    header_row = [t("questions.prompt"), t("questions.answer")]
    rows = questions.map { |q| [q[:prompt], answer_label(q[:answer])] }

    styled_table(pdf, [header_row] + rows) do |table|
      table.column(1).width = 90
      table.column(1).align = :center
    end
  end

  def render_summary(pdf, area)
    pdf.move_down 4
    pdf.fill_color COLORS[:muted]

    parts = [t("summary.counts", si: area[:yes_count], no: area[:no_count], incerto: area[:unknown_count])]
    if area[:completed_at]
      parts << t("summary.completed_at", date: I18n.l(area[:completed_at].to_date, format: :short))
    end

    pdf.text parts.join("   ·   "), size: 9
    pdf.fill_color COLORS[:black]
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

  def muted_note(pdf, text)
    pdf.fill_color COLORS[:muted]
    pdf.text text, size: 10, style: :italic
    pdf.fill_color COLORS[:black]
    pdf.move_down 15
  end

  def status_label(status)
    t("status.#{status}")
  end

  def answer_label(answer)
    return t("answer.none") if answer.blank?
    t("answer.#{answer}", default: t("answer.none"))
  end
end
