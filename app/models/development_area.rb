# frozen_string_literal: true

class DevelopmentArea < ApplicationRecord
  include Sluggable

  has_many :age_band_questionnaires, -> { order(:min_age_months) }, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }

  def self.slug_source
    :name
  end

  def questionnaire_for_age(months)
    age_band_questionnaires.find_by(
      "min_age_months <= ? AND max_age_months > ?", months, months
    )
  end
end
