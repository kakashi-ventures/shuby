# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :age_band_questionnaire
  has_many :question_responses, dependent: :destroy

  validates :prompt, presence: true
  validates :position, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }
end
