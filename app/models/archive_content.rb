# frozen_string_literal: true

class ArchiveContent < ApplicationRecord
  include Sluggable

  ARTICLE_CATEGORIES = [
    "Abilità motorie", "Attaccamento", "Benessere familiare",
    "Comunicazione", "Neurosviluppo", "Sonno"
  ].freeze

  TIP_CATEGORIES = [
    "Giochi", "Lettura"
  ].freeze

  CATEGORIES_BY_TYPE = {
    "article" => ARTICLE_CATEGORIES,
    "tip" => TIP_CATEGORIES
  }.freeze

  # Enums
  enum :content_type, {
    article: 0,
    tip: 1,
    activity: 2
  }, prefix: true

  # Rich text
  has_rich_text :body

  # ActiveStorage
  has_one_attached :cover_image

  # Favorites
  has_many :archive_favorites, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :slug, presence: true
  validates :content_type, presence: true
  validates :category, inclusion: {
    in: ->(record) { ArchiveContent::CATEGORIES_BY_TYPE.fetch(record.content_type.to_s, []) },
    message: "non è valida per questo tipo di contenuto"
  }, allow_blank: true, unless: :content_type_activity?
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
  scope :tips, -> { content_type_tip }
  scope :activities, -> { content_type_activity }

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
