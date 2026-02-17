# frozen_string_literal: true

module DashboardHelper
  def dashboard_nav_card(path:, icon_bg:, title:, subtitle:, badge: nil, &)
    link_to path, class: "flex items-center gap-4 p-4 bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 hover:shadow-md transition-shadow" do
      content = tag.div(class: "w-10 h-10 rounded-xl #{icon_bg} dark:bg-gray-700 flex items-center justify-center flex-shrink-0") { capture(&) }
      content += tag.div(class: "flex-1 min-w-0") do
        tag.h3(title, class: "shuby-p1 font-semibold text-gray-900 dark:text-white text-sm") +
          tag.p(subtitle, class: "shuby-p2 text-gray-500 dark:text-gray-400 text-xs truncate")
      end
      content += if badge
        tag.span(badge, class: "shuby-badge shuby-badge-primary text-xs")
      else
        render("shared/chevron_right_icon")
      end
      content
    end
  end
end
