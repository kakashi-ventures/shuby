# frozen_string_literal: true

class PediatricianQuestion < ApplicationRecord
  belongs_to :child

  validates :body, presence: true, length: {maximum: 500}

  scope :ordered, -> { order(:position, :created_at) }
end
