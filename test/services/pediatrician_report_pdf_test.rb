# frozen_string_literal: true

require "test_helper"

class PediatricianReportPdfTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    @data = ReportDataAggregator.call(@child)
  end

  # === Valid PDF output ===

  test "renders a valid PDF binary" do
    pdf = PediatricianReportPdf.call(@data)
    assert_kind_of String, pdf
    assert pdf.start_with?("%PDF"), "Expected PDF header"
    assert pdf.length > 1000, "PDF should have substantial content"
  end

  test "PDF contains multiple pages or at least one page" do
    pdf = PediatricianReportPdf.call(@data)
    # PDF page objects are marked with /Type /Page
    assert_match(/\/Type\s*\/Page/, pdf)
  end

  # === Different child profiles ===

  test "renders PDF for premature child" do
    luca = children(:luca)
    data = ReportDataAggregator.call(luca)
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
    assert pdf.length > 1000
  end

  test "renders PDF for inactive child" do
    marco = children(:marco_inactive)
    data = ReportDataAggregator.call(marco)
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  # === Empty data handling ===

  test "renders PDF with empty measurements" do
    child = children(:luca)
    child.measurements.destroy_all
    data = ReportDataAggregator.call(child)
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with empty questionnaires" do
    data = @data.dup
    data[:questionnaires] = []
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with empty pediatrician questions" do
    data = @data.dup
    data[:pediatrician_questions] = []
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with no notes" do
    data = @data.dup
    data[:notes] = nil
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with notes present" do
    data = @data.dup
    data[:notes] = "Important note for the pediatrician visit"
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
    # PDF with notes should be slightly larger
    pdf_without_notes = PediatricianReportPdf.call(@data.merge(notes: nil))
    assert pdf.length > pdf_without_notes.length,
      "PDF with notes should be larger than without"
  end

  # === Edge cases ===

  test "renders PDF with measurement alerts" do
    @child.measurements.create!(
      measurement_type: :weight,
      value: 2500,
      measured_at: 1.day.ago,
      percentile: 1
    )

    data = ReportDataAggregator.call(@child)
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
    assert data[:measurements][:alerts].any?, "Should have alerts for extreme percentile"
  end

  test "renders PDF with many pediatrician questions" do
    data = @data.dup
    data[:pediatrician_questions] = Array.new(10) { |i| "Domanda numero #{i + 1} per il pediatra" }
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with empty general_info" do
    data = @data.dup
    data[:general_info] = {}
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  test "renders PDF with all development areas not completed" do
    data = @data.dup
    data[:development] = data[:development].map { |d| d.merge(completed: false) }
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
  end

  # === Class interface ===

  test "responds to call class method" do
    assert_respond_to PediatricianReportPdf, :call
  end

  # === Measurement photo embedding ===

  test "renders PDF when a measurement has an attached photo" do
    m = @child.measurements.first
    m.photo.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.jpg")),
      filename: "scale.jpg",
      content_type: "image/jpeg"
    )

    data = ReportDataAggregator.call(@child)
    pdf = PediatricianReportPdf.call(data)

    assert pdf.start_with?("%PDF")
    assert pdf.length > 1000
  end

  test "renders PDF gracefully when photo variant fails" do
    m = @child.measurements.first
    fake_photo = Object.new
    def fake_photo.variant(*) = raise StandardError, "boom"
    row = {
      type: m.measurement_type,
      display_value: m.display_value,
      percentile: m.percentile,
      measured_at: m.measured_at,
      photo: fake_photo
    }
    data = @data.deep_dup
    data[:measurements][:recent] = [row]

    pdf = PediatricianReportPdf.call(data)
    assert pdf.start_with?("%PDF")
  end
end
