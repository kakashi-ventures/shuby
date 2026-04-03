# frozen_string_literal: true

module Timeline
  # Canonical sequence of age band pills for the Timeline carousel.
  # Maps UI pills (Sett. 1-8, Mese 3-36) to age_months for data lookups.
  #
  # Week-to-month mapping:
  #   Sett. 1-4 → age_months 0 (newborn, ~0-4 weeks)
  #   Sett. 5-8 → age_months 1 (~4-8 weeks)
  #   Mese 3+   → age_months = month number
  class AgeBands
    WEEKS = (1..8).map { |w|
      {
        key: "sett_#{w}",
        label_type: "Sett.",
        label_number: w,
        age_months: (w <= 4) ? 0 : 1
      }
    }.freeze

    MONTHS = (3..36).map { |m|
      {
        key: "mese_#{m}",
        label_type: "Mese",
        label_number: m,
        age_months: m
      }
    }.freeze

    ALL = (WEEKS + MONTHS).freeze

    def self.find_by_key(key)
      ALL.find { |band| band[:key] == key }
    end

    # Find the best-matching band for a child's age in months.
    # Pass age_in_weeks: for week-precision selection in the Sett. 1-8 range.
    # For ages 0-1 without weeks, falls back to a midpoint approximation.
    # For age 2, maps to Mese 3 (no Mese 2 pill exists).
    # For ages 3+, maps to the matching Mese pill.
    def self.for_child_age(age_in_months, age_in_weeks: nil)
      clamped = age_in_months.clamp(0, 36)

      if clamped <= 1 && age_in_weeks && age_in_weeks <= 8
        ALL.find { |band| band[:key] == "sett_#{age_in_weeks}" } || ALL[7]
      elsif clamped <= 1
        # Fallback approximation when week precision is unavailable
        ALL[clamped == 0 ? 3 : 7]
      elsif clamped == 2
        MONTHS.first # Mese 3 — first monthly pill; covers the same 2-5 DB band as age 2
      else
        ALL.find { |band| band[:key] == "mese_#{clamped}" } || ALL.last
      end
    end
  end
end
