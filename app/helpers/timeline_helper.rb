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
    elsif age_relationship_for(band, child) == :past
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
    else
      age_relationship_for(band, child).to_s
    end
  end
end
