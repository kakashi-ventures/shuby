# frozen_string_literal: true

module DashboardHelper
  def dashboard_nav_card(path:, icon_bg:, title:, subtitle:, badge: nil, badge_class: "shuby-badge shuby-badge-primary text-xs", &)
    link_to path, class: "shuby-nav-card", aria: { label: title } do
      content = tag.div(class: "shuby-nav-card-icon #{icon_bg}") { capture(&) }
      content += tag.div(class: "shuby-nav-card-content") do
        tag.h3(title, class: "shuby-nav-card-title") +
          tag.p(subtitle, class: "shuby-nav-card-subtitle")
      end
      content += if badge
        tag.span(badge, class: badge_class)
      else
        render("shared/chevron_right_icon")
      end
      content
    end
  end
end
