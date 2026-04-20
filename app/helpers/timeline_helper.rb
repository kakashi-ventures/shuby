# frozen_string_literal: true

module TimelineHelper
  MEASUREMENT_TYPES = %i[weight height head_circumference].freeze

  # Renders a single WHO reference measurement box.
  # Called once per type in _timeline_measurements to avoid repetition.
  # Visual spec: .shuby-who-box component (see timeline.css).
  def timeline_measurement_box(type:, ranges:)
    data = ranges&.dig(type)
    return unless data

    tag.div(class: "shuby-who-box") do
      safe_join([
        tag.p(t("timeline.show.#{type}"), class: "shuby-who-box-label"),
        tag.div(class: "shuby-who-box-range") {
          safe_join([
            tag.span(data[:p3], class: "shuby-who-box-value"),
            tag.span(class: "shuby-who-box-separator"),
            tag.span(data[:p97], class: "shuby-who-box-value")
          ])
        },
        tag.p(t("timeline.show.#{type}_unit"), class: "shuby-who-box-unit")
      ])
    end
  end

  # Full-word H2 label for the age band displayed above the narrative.
  # Figma shows the expanded form (e.g., "Settimana 6" / "Mese 5"); the abbreviated
  # label stored in band[:label_type] is used only inside pills.
  def timeline_band_title(band)
    scale = band[:key].start_with?("sett_") ? "week" : "month"
    t("timeline.show.band_title.#{scale}", number: band[:label_number])
  end

  # Determines the CSS class for a pill based on its relationship to the child's age
  # and whether it's the currently selected pill.
  def pill_state_class(band, current_band, selected_band, child)
    if band[:key] == selected_band[:key]
      "selected"
    elsif band_before_current?(band, current_band, child)
      "past"
    elsif band[:key] == current_band[:key]
      "selected-primary"
    else
      "selected-outline"
    end
  end

  # Returns :past, :current, or :future relative to the child's carousel-current
  # band (not their exact age). Uses the same mapping as Timeline::AgeBands.for_child_age
  # so the "selected-current" pill in the carousel and the overlay condition agree —
  # e.g. a 2-month-old whose current band is Mese 3 does not see the future-band
  # paywall on their own current pill.
  def age_relationship_for(band, child)
    current = Timeline::AgeBands.for_child_age(
      child.questionnaire_age_in_months,
      age_in_weeks: child.questionnaire_age_in_weeks
    )
    return :current if band[:key] == current[:key]

    all = Timeline::AgeBands::ALL
    band_idx = all.index { |b| b[:key] == band[:key] } || 0
    current_idx = all.index { |b| b[:key] == current[:key] } || 0
    (band_idx < current_idx) ? :past : :future
  end

  # Returns the data-band-relationship attribute value for a pill.
  def pill_relationship(band, current_band, child)
    if band[:key] == current_band[:key]
      "current"
    elsif band_before_current?(band, current_band, child)
      "past"
    else
      "future"
    end
  end

  private

  # True when +band+ falls strictly before +current_band+ in the timeline sequence.
  # Uses age_months for most bands; falls back to ALL-array position for week bands
  # that share the same age_months (Sett. 1-4 → 0, Sett. 5-8 → 1).
  def band_before_current?(band, current_band, child)
    rel = age_relationship_for(band, child)
    return true if rel == :past
    return false if rel == :future

    # Same age_months: resolve by position in the canonical sequence
    all = Timeline::AgeBands::ALL
    all.index { |b| b[:key] == band[:key] }.to_i <
      all.index { |b| b[:key] == current_band[:key] }.to_i
  end
end
