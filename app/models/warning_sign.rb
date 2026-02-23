# frozen_string_literal: true

class WarningSign < ApplicationRecord
  validates :month, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 36 }
  validates :description, presence: true

  scope :for_month, ->(month) { where(month: month).order(:position) }
  scope :ordered, -> { order(:month, :position) }
end
