# frozen_string_literal: true

class TimelineStageContent < ApplicationRecord
  PILL_KEY_FORMAT = /\A(sett|mese)_\d+\z/

  validates :pill_key,
    presence: true,
    uniqueness: true,
    format: {with: PILL_KEY_FORMAT}
  validates :description, presence: true

  scope :ordered, -> { order(:position) }

  def self.for_band(band)
    return nil if band.blank?

    find_by(pill_key: band[:key])
  end

  def weekly?
    pill_key.to_s.start_with?("sett_")
  end

  def monthly?
    pill_key.to_s.start_with?("mese_")
  end
end
