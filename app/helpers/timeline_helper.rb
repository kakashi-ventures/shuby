# frozen_string_literal: true

module TimelineHelper
  MEASUREMENT_CONFIG = [
    {type: :weight, label_key: "timeline.show.weight", unit: "kg"},
    {type: :height, label_key: "timeline.show.height", unit: "cm"},
    {type: :head_circumference, label_key: "timeline.show.head_circumference", unit: "cm"}
  ].freeze

  # Renders a single WHO reference measurement box.
  # Called 3 times in _section_measurements to avoid repetition.
  def timeline_measurement_box(type:, ranges:, unit:)
    data = ranges&.dig(type)
    return unless data

    tag.div(class: "flex-1 rounded-lg bg-white p-3 text-center") do
      safe_join([
        tag.p(t("timeline.show.#{type}"), class: "shuby-caption text-shuby-blue-800 font-semibold uppercase mb-1"),
        tag.p(class: "font-display font-bold text-lg text-shuby-blue-800") {
          safe_join([
            tag.span(data[:p3], class: "text-base"),
            tag.span(" "),
            tag.span(data[:p97], class: "text-base")
          ])
        },
        tag.p(unit, class: "shuby-caption text-shuby-gray-600")
      ])
    end
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

  # Returns :past, :current, or :future relative to the child's actual age.
  def age_relationship_for(band, child)
    child_age = child.questionnaire_age_in_months
    if band[:age_months] < child_age
      :past
    elsif band[:age_months] == child_age
      :current
    else
      :future
    end
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
