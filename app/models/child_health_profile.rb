# frozen_string_literal: true

class ChildHealthProfile < ApplicationRecord
  belongs_to :child

  # Gestational age categories
  enum :gestational_age_category, {
    very_preterm: 0,        # < 28 weeks
    moderate_preterm: 1,    # 28-31+6 weeks
    late_preterm_early: 2,  # 32-34+6 weeks
    late_preterm_late: 3,   # 35-36+6 weeks
    full_term: 4            # >= 37 weeks
  }, prefix: true

  # Pregnancy type
  enum :pregnancy_type, {
    natural: 0,
    ivf_homologous: 1,
    ivf_donor_egg: 2,
    ivf_donor_sperm: 3,
    iui: 4,
    fivet_icsi: 5,
    pregnancy_other: 6,
    pregnancy_unknown: 7
  }, prefix: true

  # Yes/No/Unknown enums
  enum :hospitalized_after_birth, {hosp_yes: 0, hosp_no: 1, hosp_unknown: 2}, prefix: true
  enum :birth_weight_under_1500, {weight_yes: 0, weight_no: 1, weight_unknown: 2}, prefix: true
  enum :required_oxygen_ventilation, {oxygen_yes: 0, oxygen_no: 1, oxygen_unknown: 2}, prefix: true

  # Screening results
  enum :hearing_screening_result, {hearing_pass: 0, hearing_refer: 1, hearing_not_done: 2, hearing_unknown: 3}, prefix: true
  enum :vision_screening_result, {vision_done: 0, vision_not_yet: 1, vision_unknown: 2}, prefix: true

  # Feeding type
  enum :current_feeding_type, {breastfeeding: 0, formula: 1, mixed: 2, feeding_other: 3}, prefix: true

  # Birth complication options
  BIRTH_COMPLICATIONS = %w[
    respiratory_difficulties
    jaundice_phototherapy
    infection
    hypoglycemia
    complication_other
    complication_unknown
  ].freeze

  # Sleep quality issues
  SLEEP_QUALITY_ISSUES = %w[
    snores
    moves_a_lot
    wakes_often
    cries
    difficulty_falling_asleep
    difficulty_waking
    teeth_grinding
    sleep_other
  ].freeze

  # Scheduled follow-ups for premature babies
  SCHEDULED_FOLLOWUPS = %w[hearing vision motor respiratory followup_other].freeze

  # Validations
  validates :birth_weight_grams, numericality: {greater_than: 0, less_than: 10000}, allow_nil: true
  validates :average_sleep_hours, numericality: {greater_than: 0, less_than_or_equal_to: 24}, allow_nil: true
  validates :floor_play_minutes_per_day, numericality: {greater_than_or_equal_to: 0, less_than: 1440}, allow_nil: true
  validate :premature_fields_consistency

  def premature?
    gestational_age_category.present? && !gestational_age_category_full_term?
  end

  def birth_complications_list
    birth_complications || []
  end

  def sleep_quality_issues_list
    sleep_quality_issues || []
  end

  def scheduled_followups_list
    scheduled_followups || []
  end

  private

  def premature_fields_consistency
    return unless child&.gestational_weeks.present?

    is_term = child.gestational_weeks >= 37

    if is_term
      # Term babies shouldn't have these premature-specific responses
      if birth_weight_under_1500.present? && birth_weight_under_1500_weight_yes?
        errors.add(:birth_weight_under_1500, :not_applicable_for_term)
      end

      if required_oxygen_ventilation.present? && required_oxygen_ventilation_oxygen_yes?
        errors.add(:required_oxygen_ventilation, :not_applicable_for_term)
      end

      # Check if premature follow-ups are scheduled
      premature_followups = scheduled_followups_list & %w[hearing vision motor respiratory]
      if premature_followups.any?
        errors.add(:scheduled_followups, :not_applicable_for_term,
                   followups: premature_followups.join(", "))
      end
    end
  end
end
