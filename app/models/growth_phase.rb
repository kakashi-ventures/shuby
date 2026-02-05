# frozen_string_literal: true

class GrowthPhase < ApplicationRecord
  validates :title, :description, presence: true
  validates :min_age_months, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 36}
  validates :max_age_months, numericality: {greater_than: 0, less_than_or_equal_to: 37}

  scope :ordered, -> { order(:min_age_months, :position) }

  def self.for_age(months)
    where("min_age_months <= ? AND max_age_months > ?", months, months).ordered.first
  end

  def illustration_path
    illustration_key.present? ? "shuby/illustrations/#{illustration_key}" : "shuby/illustrations/growth-phase-mascot.svg"
  end
end
