# frozen_string_literal: true

module ArchiveHelper
  # Maps category names to icon paths
  CATEGORY_ICONS = {
    "Abilità motorie" => "shuby/icons/icon-barefoot",
    "Attaccamento" => "shuby/icons/icon-attachment",
    "Benessere familiare" => "shuby/icons/icon-heart-filled",
    "Comunicazione" => "shuby/icons/icon-document",
    "Neurosviluppo" => "shuby/icons/icon-neurodevelopment",
    "Sonno" => "shuby/icons/icon-moon",
    "Giochi" => "shuby/icons/icon-barefoot",
    "Lettura" => "shuby/icons/icon-reading"
  }.freeze

  DEFAULT_CATEGORY_ICON = "shuby/icons/icon-document"

  # Returns the icon path for a given category
  #
  # @param category [String] The category name
  # @return [String] The icon path
  def category_icon_for(category)
    return "shuby/icons/icon-tips" if category.blank?

    CATEGORY_ICONS[category] || DEFAULT_CATEGORY_ICON
  end

  ARCHIVE_PLACEHOLDER_IMAGES = [
    "shuby/illustrations/archive-1.svg",
    "shuby/illustrations/archive-2.svg",
    "shuby/illustrations/archive-3.svg"
  ].freeze

  # Returns the cover image tag for an ArchiveContent, falling back to a
  # cycling placeholder illustration when no cover image is attached.
  def archive_cover_image(content, **)
    if content.cover_image.attached?
      image_tag(content.cover_image, alt: content.title, **)
    else
      image_tag(ARCHIVE_PLACEHOLDER_IMAGES[content.id % 3], alt: "", **)
    end
  end

  # Returns the content type icon path
  #
  # @param content_type [String] The content type (article, book, game, tip)
  # @return [String] The icon path
  def content_type_icon_for(content_type)
    case content_type.to_s
    when "article" then "shuby/icons/icon-document"
    when "tip" then "shuby/icons/icon-tips"
    when "activity" then "shuby/icons/icon-barefoot"
    else "shuby/icons/icon-document"
    end
  end

  # Renders a Tip recommendation item with inline **bold** markdown-style
  # markup (Figma 532:25861/26226 — bold lead phrase or in-sentence emphasis).
  # Safe: HTML-escape the input first, then re-introduce only <strong>.
  def recommendation_html(item)
    escaped = ERB::Util.html_escape(item.to_s)
    escaped.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>').html_safe
  end
end
