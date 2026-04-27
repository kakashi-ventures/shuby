# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :age_band_questionnaire
  has_many :question_responses, dependent: :destroy

  validates :prompt, presence: true
  validates :position, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }

  def illustration_path
    area_slug = age_band_questionnaire&.development_area&.slug
    if illustration_key.present? && area_slug.present?
      "shuby/illustrations/questions/#{area_slug}/#{illustration_key}.png"
    end
  end

  # Many seeded questions point at illustration assets that have not yet been
  # delivered by design. Guard the view render against broken images by
  # checking the source PNG actually exists in the assets pipeline.
  def illustration_available?
    path = illustration_path
    return false if path.blank?
    Rails.root.join("app/assets/images", path).file?
  end
end
