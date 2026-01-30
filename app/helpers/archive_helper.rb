# frozen_string_literal: true

module ArchiveHelper
  # Maps category names to icon paths
  CATEGORY_ICONS = {
    "Abilità motorie" => "shuby/icons/icon-footprints",
    "Motricità" => "shuby/icons/icon-footprints",
    "Benessere familiare" => "shuby/icons/icon-heart",
    "Benessere" => "shuby/icons/icon-heart",
    "Neurosviluppo" => "shuby/icons/icon-brain",
    "Attaccamento" => "shuby/icons/icon-hands-heart",
    "Comunicazione" => "shuby/icons/icon-docs",
    "Linguaggio" => "shuby/icons/icon-docs",
    "Lettura" => "shuby/icons/icon-book",
    "Giochi" => "shuby/icons/icon-footprints"
  }.freeze

  DEFAULT_CATEGORY_ICON = "shuby/icons/icon-docs"

  # Returns the icon path for a given category
  #
  # @param category [String] The category name
  # @return [String] The icon path
  def category_icon_for(category)
    return DEFAULT_CATEGORY_ICON if category.blank?

    CATEGORY_ICONS[category] || DEFAULT_CATEGORY_ICON
  end

  # Returns the content type icon path
  #
  # @param content_type [String] The content type (article, book, game, tip)
  # @return [String] The icon path
  def content_type_icon_for(content_type)
    case content_type.to_s
    when "article" then "shuby/icons/icon-docs"
    when "book" then "shuby/icons/icon-book"
    when "game" then "shuby/icons/icon-footprints"
    when "tip" then "shuby/icons/icon-heart"
    else "shuby/icons/icon-docs"
    end
  end
end
