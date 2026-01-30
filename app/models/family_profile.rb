# frozen_string_literal: true

class FamilyProfile < AccountRecord
  belongs_to :account

  enum :family_structure, {
    single_parent: 0,
    two_parents: 1,
    foster: 2,
    adoptive: 3,
    other: 4
  }, prefix: true

  enum :two_parents_type, {
    unspecified: 0,
    male_male: 1,
    female_female: 2,
    prefer_not_to_say: 3
  }, prefix: true

  # Validations
  validates :country, presence: true
  validates :number_of_children, numericality: {greater_than: 0, less_than_or_equal_to: 10}
  validates :languages_spoken_at_home, numericality: {greater_than: 0, less_than_or_equal_to: 10}

  # Normalize text fields to strip whitespace
  normalizes :country, :nationality, :mother_tongue, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ") : value }

  # Primary caregiver options
  CAREGIVER_OPTIONS = %w[parents grandparents educators other].freeze

  # Hereditary condition options
  HEREDITARY_CONDITIONS = %w[
    language_difficulties
    attention_hyperactivity
    behavioral_difficulties
    autism_spectrum
    other
  ].freeze

  def caregivers_list
    primary_caregivers || []
  end

  def hereditary_conditions_list
    hereditary_conditions || []
  end

  # Profile completeness tracking
  def profile_completeness_percentage
    required_fields = [nationality, country, mother_tongue]
    filled = required_fields.count(&:present?)
    (filled.to_f / required_fields.size * 100).round
  end

  def profile_complete?
    profile_completeness_percentage >= 100
  end
end
