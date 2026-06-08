# frozen_string_literal: true

class PediatricianReportsController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child

  def show
    data = ReportDataAggregator.call(@child, sections: current_user.pdf_pediatrician_sections)
    pdf = PediatricianReportPdf.call(data)
    filename = "shuby-report-#{@child.display_name.parameterize}-#{Date.current}.pdf"

    send_data pdf,
      filename: filename,
      type: "application/pdf",
      disposition: "inline"
  end
end
