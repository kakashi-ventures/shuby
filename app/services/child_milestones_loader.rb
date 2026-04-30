# frozen_string_literal: true

# Single source of truth for milestone data on a Child. Two views consume it:
#
#   * Tappe tab (children#show, tab=milestones) uses #call — accordion of every
#     past + current band.
#   * Timeline page (development_stages#index, #timeline_content) uses
#     #data_for_band — the single band the user has selected via the carousel,
#     including future bands (which trigger the premium overlay upstream).
#
# Both consumers receive identical band-data shapes, so they share the milestone
# card partials. Band relationship is decided strictly by position in
# Timeline::AgeBands::ALL — band-key equality with the child's current band —
# rather than by AgeBandQuestionnaire range overlap, which would conflate
# adjacent bands sharing a questionnaire (e.g. sett_5..sett_8 all map to
# age_months=1).
class ChildMilestonesLoader
  def initialize(child)
    @child = child
  end

  # All past + current bands, current first, then past in reverse chronological order.
  def call
    {
      current_band: current_band,
      bands: bands_to_show.map { |band| build_band_data(band) }
    }
  end

  # Single-band data for the timeline page. Accepts any band — past, current, or future.
  def data_for_band(band)
    build_band_data(band)
  end

  def current_band
    @current_band ||= Timeline::AgeBands.for_child_age(
      child.questionnaire_age_in_months,
      age_in_weeks: child.questionnaire_age_in_weeks
    )
  end

  private

  attr_reader :child

  # Bands from the very first up to and including the current band, sorted current-first.
  # Indexed by position in AgeBands::ALL (not by age_months) so adjacent bands sharing
  # the same age_months — e.g. sett_5..sett_8 all map to age_months=1 — don't all leak
  # into the list when the child is only at sett_6.
  def bands_to_show
    Timeline::AgeBands::ALL[0..current_band_index].reverse
  end

  def current_band_index
    @current_band_index ||= Timeline::AgeBands::ALL.find_index { |b| b[:key] == current_band[:key] }
  end

  def build_band_data(band)
    relationship = relationship_for(band)
    development_areas = development_areas_for(band[:age_months], relationship)

    {
      band: band,
      development_areas: development_areas,
      completed_count: development_areas.count { |d| d[:session]&.completed? },
      total_count: development_areas.count { |d| d[:questionnaire].present? },
      age_relationship: relationship
    }
  end

  def relationship_for(band)
    return :current if band[:key] == current_band[:key]

    band_index = Timeline::AgeBands::ALL.find_index { |b| b[:key] == band[:key] }
    return :past if band_index.nil? # defensive: unknown band keys behave like past
    (band_index < current_band_index) ? :past : :future
  end

  def development_areas_for(age_months, relationship)
    DevelopmentArea.ordered.includes(:age_band_questionnaires).map do |area|
      questionnaire = area.questionnaire_for_age(age_months)
      session = session_for(questionnaire, relationship)

      {
        area: area,
        questionnaire: questionnaire,
        session: session,
        age_relationship: relationship
      }
    end
  end

  def session_for(questionnaire, relationship)
    return nil unless questionnaire

    if relationship == :current
      child.session_for(questionnaire) || latest_completed_session(questionnaire)
    else
      latest_completed_session(questionnaire)
    end
  end

  def latest_completed_session(questionnaire)
    child.questionnaire_sessions
      .where(age_band_questionnaire: questionnaire)
      .completed
      .recent_first
      .first
  end
end
