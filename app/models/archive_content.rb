# frozen_string_literal: true

class ArchiveContent < ApplicationRecord
  include Sluggable

  # Enums
  enum :content_type, {
    article: 0,
    book: 1,
    game: 2,
    tip: 3
  }, prefix: true

  # ActiveStorage
  has_one_attached :cover_image

  # Favorites
  has_many :archive_favorites, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :slug, presence: true
  validates :content_type, presence: true
  validates :min_age_months, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 36
  }
  validates :max_age_months, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 36
  }
  validate :max_age_greater_than_min

  # Scopes
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :for_age, ->(months) {
    where("min_age_months <= ? AND max_age_months >= ?", months, months)
  }
  scope :by_type, ->(type) { where(content_type: type) }
  scope :articles, -> { content_type_article }
  scope :books, -> { content_type_book }
  scope :games, -> { content_type_game }
  scope :tips, -> { content_type_tip }

  # Instance methods
  def age_range_label
    if min_age_months == 0 && max_age_months >= 36
      "0-36 mesi"
    elsif min_age_months == max_age_months
      "#{min_age_months} mesi"
    else
      "#{min_age_months}-#{max_age_months} mesi"
    end
  end

  def duration_label
    return nil unless duration_minutes
    "#{duration_minutes} min"
  end

  private

  def max_age_greater_than_min
    return unless min_age_months && max_age_months
    if max_age_months < min_age_months
      errors.add(:max_age_months, "must be greater than or equal to min age")
    end
  end
end
