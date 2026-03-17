# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug
  end

  class_methods do
    def slug_source
      :title
    end
  end

  private

  def generate_slug
    source_value = public_send(self.class.slug_source)
    return if source_value.blank?

    if slug.blank? || (persisted? && will_save_change_to_attribute?(self.class.slug_source))
      base_slug = source_value.parameterize
      self.slug = unique_slug(base_slug)
    end
  end

  def unique_slug(base_slug)
    candidate = base_slug
    counter = 2
    scope = self.class.where.not(id: id)

    while scope.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    candidate
  end
end
