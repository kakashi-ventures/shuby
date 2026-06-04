# frozen_string_literal: true

module ShubyChatsHelper
  # Tags/attributes allowed through after markdown rendering. The renderer is
  # configured with filter_html + safe_links_only, so this sanitize pass is
  # defense-in-depth for LLM-generated content.
  CHAT_MD_TAGS = %w[p br h1 h2 h3 h4 strong em del a ul ol li blockquote code pre
    table thead tbody tr th td hr].freeze
  CHAT_MD_ATTRS = %w[href].freeze

  # HTML renderer options — strip raw HTML, block image/style injection, allow
  # only safe link schemes (relative /archive links + http/https/mailto).
  CHAT_MD_RENDER_OPTIONS = {
    filter_html: true,
    no_images: true,
    no_styles: true,
    safe_links_only: true,
    hard_wrap: false
  }.freeze

  # GFM extensions the assistant is prompted to use (see
  # ShubyAssistantService::BASE_SYSTEM_PROMPT). lax_spacing parses blocks that
  # lack blank-line separation — common in terse LLM markdown.
  CHAT_MD_EXTENSIONS = {
    tables: true,
    fenced_code_blocks: true,
    autolink: true,
    strikethrough: true,
    lax_spacing: true,
    no_intra_emphasis: true
  }.freeze

  # Renders assistant message markdown to sanitized HTML.
  #
  # @param text [String, nil] The raw markdown content
  # @return [ActiveSupport::SafeBuffer] Sanitized, render-safe HTML
  def render_chat_markdown(text)
    return "".html_safe if text.blank?

    renderer = Redcarpet::Render::HTML.new(CHAT_MD_RENDER_OPTIONS)
    html = Redcarpet::Markdown.new(renderer, CHAT_MD_EXTENSIONS).render(text)
    sanitize(html, tags: CHAT_MD_TAGS, attributes: CHAT_MD_ATTRS)
  end
end
