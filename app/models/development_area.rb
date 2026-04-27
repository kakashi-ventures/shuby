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

  def illustration_path
    candidate = "shuby/illustrations/categories/#{illustration_key}.png" if illustration_key.present?
    if candidate && Rails.root.join("app/assets/images", candidate).file?
      candidate
    else
      "shuby/illustrations/growth-phase-mascot.svg"
    end
  end
end
