# frozen_string_literal: true

class DevelopmentArea < ApplicationRecord
  has_many :age_band_questionnaires, -> { order(:min_age_months) }, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }

  before_validation :generate_slug, on: :create

  def questionnaire_for_age(months)
    age_band_questionnaires.find_by(
      "min_age_months <= ? AND max_age_months > ?", months, months
    )
  end

  private

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
