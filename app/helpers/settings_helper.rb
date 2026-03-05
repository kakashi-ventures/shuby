# frozen_string_literal: true

module SettingsHelper
  # Renders a settings navigation card with an SVG icon.
  # SAFETY: icon_svg must contain only trusted, static SVG path data (never user input).
  def settings_link_card(path:, icon_svg:, title:, description:, icon_bg: "bg-primary-100", icon_color: "text-primary-600")
    link_to path, class: "shuby-card hover:shadow-md transition-shadow" do
      tag.div(class: "flex items-center justify-between") do
        tag.div(class: "flex items-center gap-4") do
          tag.div(class: "w-12 h-12 rounded-full #{icon_bg} flex items-center justify-center") do
            tag.svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "currentColor",
              class: "w-6 h-6 #{icon_color}") do
              icon_svg.html_safe
            end
          end +
            tag.div do
              tag.h3(title, class: "shuby-h3") +
                tag.p(description, class: "shuby-caption")
            end
        end +
          render_svg("shuby/icons/icon-chevron-right", size: :md, styles: "text-gray-400", decorative: true)
      end
    end
  end
end
