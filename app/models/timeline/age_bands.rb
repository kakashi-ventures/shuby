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
    # For ages 0-1, maps to weeks; for 2, maps to Sett. 8 (last week);
    # for 3+, maps to the matching Mese pill.
    def self.for_child_age(age_in_months)
      clamped = age_in_months.clamp(0, 36)

      if clamped <= 1
        # Map to a week pill based on approximate week count
        week_index = if clamped == 0
          3 # Sett. 4 (mid-point of first month)
        else
          7 # Sett. 8 (end of second month)
        end
        ALL[week_index]
      elsif clamped == 2
        ALL[7] # Sett. 8 — closest pill before Mese 3
      else
        ALL.find { |band| band[:key] == "mese_#{clamped}" } || ALL.last
      end
    end
  end
end
