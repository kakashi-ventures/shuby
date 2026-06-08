# frozen_string_literal: true

# Streams a single age band's questionnaire-results PDF — the per-stage download
# from the milestones accordion (Tappe tab). Free for any user who can view the
# child. Future bands are not exportable: the accordion never links to them and
# they hold no answered data yet, so their export 404s.
class StageReportsController < ApplicationController
  include ChildScoped

  before_action :authenticate_user!
  before_action :set_child
  before_action :set_band

  def show
    data = StageReportDataAggregator.call(@child, @band,
      include_question_details: current_user.pdf_stage_question_details)
    pdf = StageReportPdf.call(data)

    send_data pdf,
      filename: filename,
      type: "application/pdf",
      disposition: "attachment"
  end

  private

  # :id is the age-band key (e.g. "sett_5", "mese_12").
  def set_band
    @band = Timeline::AgeBands.find_by_key(params[:id])
    head :not_found unless @band && band_reached?
  end

  # Only past + current bands are exportable — the same set the milestones
  # accordion renders. A future band sits beyond the child's current position.
  def band_reached?
    all = Timeline::AgeBands::ALL
    current = ChildMilestonesLoader.new(@child).current_band
    requested_index = all.index { |b| b[:key] == @band[:key] }
    current_index = all.index { |b| b[:key] == current[:key] }
    requested_index && current_index && requested_index <= current_index
  end

  def filename
    "shuby-tappa-#{@band[:key]}-#{@child.display_name.parameterize}-#{Date.current}.pdf"
  end
end
