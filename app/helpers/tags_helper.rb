module TagsHelper
  # Figma variant name → CSS class suffix mapping.
  # Supports both Figma Italian names and direct CSS names.
  VARIANT_MAP = {
    # Figma Italian names (from Figma component properties)
    azzurro: "info",
    blu: "primary",
    fucsia: "fucsia",
    giallo: "giallo",
    giallo_scuro: "giallo-scuro",
    verde: "verde",
    verde_200: "verde-chiaro",
    grigio: "default",
    bianco: "bianco",
    trasparente: "transparent",
    # Direct CSS names (developer convenience)
    default: "default",
    light: "light",
    primary: "primary",
    magenta: "magenta",
    info: "info",
    yellow: "yellow",
    outline: "outline",
    outline_magenta: "outline-magenta"
  }.freeze

  # Maps questionnaire answer values to tag variants.
  def answer_tag_variant(answer)
    case answer
    when "si" then :verde
    when "no" then :fucsia
    else :grigio
    end
  end

  # Renders a design-system tag (pill-shaped label with optional icon).
  #
  #   shuby_tag("Lettura", variant: :giallo, icon: "shuby/icons/icon-book")
  #   shuby_tag("3-6 mesi", variant: :azzurro, size: :small)
  #   shuby_tag(variant: :primary) { "Dynamic" }
  #
  def shuby_tag(label = nil, variant: :default, size: :normal, icon: nil,
    clickable: false, selected: false, **html_options, &block)
    label = capture(&block) if block

    css_suffix = VARIANT_MAP.fetch(variant) { raise ArgumentError, "Unknown tag variant: #{variant}" }
    classes = ["shuby-tag", "shuby-tag-#{css_suffix}"]
    classes << "shuby-tag-sm" if size == :small
    classes << "shuby-tag-clickable" if clickable
    classes << "selected" if selected
    classes.concat(Array(html_options.delete(:class)))

    content = +""
    if icon
      content << tag.span(render_svg(icon, size: :xs, decorative: true), class: "shuby-tag-icon")
    end
    content << label.to_s

    tag.span(content.html_safe, class: classes.join(" "), **html_options)
  end
end
