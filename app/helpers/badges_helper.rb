module BadgesHelper
  # DEPRECATED: Prefer shuby_tag() from TagsHelper for design-system tags.
  # This helper uses raw Tailwind classes outside the Shuby design system.
  def badge(text = nil, options = {}, &block)
    text, options = nil, text || {} if block
    base = options.delete(:base) || "rounded-sm py-0.5 px-2 text-xs inline-block font-semibold leading-normal mr-2"
    color = options.delete(:color) || "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200"
    options[:class] = Array.wrap(options[:class]) + [base, color]
    tag.div(text, **options, &block)
  end
end
