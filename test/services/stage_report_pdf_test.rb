# frozen_string_literal: true

require "test_helper"

class StageReportPdfTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    @band = Timeline::AgeBands.find_by_key("sett_1")
    @data = StageReportDataAggregator.call(@child, @band)
  end

  test "renders a valid PDF binary" do
    pdf = StageReportPdf.call(@data)

    assert_kind_of String, pdf
    assert pdf.start_with?("%PDF"), "Expected PDF header"
    assert pdf.length > 1000, "PDF should have substantial content"
  end

  test "PDF has at least one page" do
    pdf = StageReportPdf.call(@data)
    assert_match(%r{/Type\s*/Page}, pdf)
  end

  test "renders even when every area is incomplete" do
    data = @data.dup
    data[:areas] = @data[:areas].map do |area|
      area.merge(status: :not_started, completed_at: nil,
        questions: area[:questions].map { |q| q.merge(answer: nil) })
    end

    pdf = StageReportPdf.call(data)
    assert pdf.start_with?("%PDF")
  end

  test "renders when a band has no available questionnaires" do
    data = {
      header: @data[:header],
      areas: [{
        area_name: "Area senza questionario",
        age_band_label: nil,
        status: :not_available,
        completed_at: nil,
        yes_count: 0, no_count: 0, unknown_count: 0,
        questions: []
      }]
    }

    pdf = StageReportPdf.call(data)
    assert pdf.start_with?("%PDF")
  end

  test "responds to call class method" do
    assert_respond_to StageReportPdf, :call
  end
end
