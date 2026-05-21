# frozen_string_literal: true

class Question < ApplicationRecord
  belongs_to :age_band_questionnaire
  has_many :question_responses, dependent: :destroy

  validates :prompt, presence: true
  validates :position, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }
  scope :with_content_key, -> { where.not(content_key: nil) }

  def equivalents
    return Question.none if content_key.blank?
    Question.where(content_key: content_key).where.not(id: id)
  end

  # Stable, comparable key derived from a prompt's text content. Strips case,
  # punctuation, and whitespace variation so byte-identical-but-formatted
  # duplicates collapse to the same key. Used by the seed loader and by the
  # migration backfill — keep the algorithm in lockstep with both.
  def self.normalize_prompt(text)
    return nil if text.blank?
    text.downcase.gsub(/[^\p{Alnum}\s]/, "").squeeze(" ").strip
  end

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
