module ImagesHelper
  ICON_SIZES = {
    xs: "w-3 h-3",   # 12px — metadata icons (alarm, category in cards)
    sm: "w-4 h-4",   # 16px — small UI (chevrons in selectors)
    md: "w-5 h-5",   # 20px — standard actions (bookmark, add, back)
    lg: "w-6 h-6",   # 24px — bottom nav, section headers
    xl: "w-8 h-8",   # 32px — showcase/featured
    xxl: "w-10 h-10" # 40px — page hero icons
  }.freeze

  def render_svg(name, options = {})
    size = options.delete(:size)
    styles = options.delete(:styles)
    decorative = options.delete(:decorative)

    css_classes = []
    css_classes << ICON_SIZES[size] if size
    css_classes << styles if styles.present?
    css_classes << "fill-current" if css_classes.empty?
    options[:class] = css_classes.join(" ")

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

  # Font Awesome icon helper
  # fa_icon "thumbs-up", weight: "fa-solid"
  # <i class="fa-solid fa-thumbs-up"></i>
  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "fa-regular"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    tag.i(nil, **options)
  end
end
