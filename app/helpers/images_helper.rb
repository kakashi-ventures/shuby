module ImagesHelper
  ICON_SIZES = {
    xs: "w-3 h-3",   # 12px — metadata icons (alarm, category in cards)
    sm: "w-4 h-4",   # 16px — small UI (chevrons in selectors)
    md: "w-5 h-5",   # 20px — standard actions (bookmark, add, back)
    lg: "w-6 h-6",   # 24px — bottom nav, section headers
    xl: "w-8 h-8",   # 32px — showcase/featured
    xxl: "w-10 h-10" # 40px — page hero icons
  }.freeze

  ICON_DIMENSIONS = {
    xs: 12, sm: 16, md: 20, lg: 24, xl: 32, xxl: 40
  }.freeze

  def render_svg(name, options = {})
    size = options.delete(:size)
    styles = options.delete(:styles)
    decorative = options.delete(:decorative)
    legacy_class = options.delete(:class)

    css_classes = []
    css_classes << ICON_SIZES[size] if size
    css_classes << styles if styles.present?
    css_classes << legacy_class if legacy_class.present?
    css_classes << "fill-current" if css_classes.empty?
    options[:class] = css_classes.join(" ")

    # Set explicit width/height attributes for reliable sizing.
    # Without these, SVGs with only viewBox (no intrinsic size) expand
    # to fill their container — causing giant icon overflow.
    if size && ICON_DIMENSIONS[size]
      dim = ICON_DIMENSIONS[size]
      options[:width] ||= dim
      options[:height] ||= dim
    else
      # Default to 24px (lg) when no size specified — prevents unbounded SVG expansion
      options[:width] ||= 24
      options[:height] ||= 24
    end

    if decorative
      options[:aria_hidden] = true
      options.delete(:title)
    else
      options[:title] ||= name.split("/").last.delete_prefix("icon-").tr("-", " ").humanize
      options[:aria] = true
    end

    options[:nocomment] = true
    inline_svg_tag("#{name}.svg", options)
  end

  LOGO_VARIANTS = {
    default: "shuby/logos/shuby_logo.png",
    white: "shuby/logos/shuby_white_logo.png",
    whitepink: "shuby/logos/shuby_whitepink_logo.png"
  }.freeze

  ICON_VARIANTS = {
    default: "shuby/logos/shuby_icon.png",
    whitepink: "shuby/logos/shuby_whitepink_icon.png"
  }.freeze

  # Renders the official Shuby brand logo (cloud-flower icon + "Shuby" text).
  # Per brand book: use :default on white, :white on dark, :whitepink on colored backgrounds.
  def shuby_logo(size: "h-7", variant: :default, **options)
    path = LOGO_VARIANTS.fetch(variant)
    css = [size, "w-auto", options.delete(:class)].compact.join(" ")
    image_tag path, alt: "Shuby", class: css, **options
  end

  # Renders the Shuby icon only (cloud-flower, no text). For favicons, small spaces.
  def shuby_icon(size: "h-8", variant: :default, **options)
    path = ICON_VARIANTS.fetch(variant)
    css = [size, "w-auto", options.delete(:class)].compact.join(" ")
    image_tag path, alt: "Shuby", class: css, **options
  end

  # Font Awesome icon helper
  # fa_icon "thumbs-up", weight: "fa-solid"
  # <i class="fa-solid fa-thumbs-up"></i>
  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "fa-regular"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    tag.i(nil, **options)
  end
end
