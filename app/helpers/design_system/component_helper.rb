# frozen_string_literal: true

module DesignSystem
  module ComponentHelper
    BOTTOM_NAV_ITEMS = [
      {key: "oggi", label: "Oggi",
       svg: '<path d="M3 3h7v7H3V3zm0 11h7v7H3v-7zm11-11h7v7h-7V3zm0 11h7v7h-7v-7z"/>'},
      {key: "ai-helper", label: "AI-helper",
       svg: '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>'},
      {key: "archivio", label: "Archivio",
       svg: '<path d="M20 6h-8l-2-2H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2z"/>'},
      {key: "gestione", label: "Gestione",
       svg: '<path d="M19.14 12.94c.04-.31.06-.63.06-.94 0-.31-.02-.63-.06-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.04.31-.06.63-.06.94s.02.63.06.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/>'}
    ].freeze

    def ds_footprint_icon_svg
      '<svg viewBox="0 0 24 24" fill="currentColor"><ellipse cx="7" cy="3.5" rx="1.3" ry="1.5"/><ellipse cx="9.5" cy="2.2" rx="1.2" ry="1.4"/><ellipse cx="12" cy="1.8" rx="1.1" ry="1.3"/><ellipse cx="14.5" cy="2.5" rx="1" ry="1.2"/><ellipse cx="16.5" cy="4" rx="0.9" ry="1.1"/><ellipse cx="11" cy="13" rx="6" ry="9"/></svg>'.html_safe
    end

    def ds_bottom_nav_example(active:, label:)
      tag.p(label, class: "shuby-p2 mb-2") +
        tag.div(class: "shuby-bottom-nav border rounded-lg mb-6") do
          safe_join(BOTTOM_NAV_ITEMS.map do |item|
            is_active = item[:key] == active
            tag.a(href: "#", class: "shuby-bottom-nav-item#{" active" if is_active}") do
              tag.div(class: "shuby-bottom-nav-icon") do
                ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">' + item[:svg] + "</svg>").html_safe
              end +
              tag.span(item[:label], class: "shuby-bottom-nav-label")
            end
          end)
        end
    end

    def ds_variables_table(variables)
      tag.table(class: "w-full text-left") do
        tag.thead do
          tag.tr do
            tag.th("Variable", class: "shuby-caption pb-2") +
              tag.th("Value", class: "shuby-caption pb-2") +
              tag.th("Usage", class: "shuby-caption pb-2")
          end
        end +
          tag.tbody do
            safe_join(variables.map do |v|
              tag.tr do
                tag.td(tag.code(v[:var]), class: "shuby-p2 py-1") +
                tag.td(v[:value], class: "shuby-p2 py-1") +
                tag.td(v[:usage], class: "shuby-p2 py-1")
              end
            end)
          end
      end
    end

    def ds_asset_grid(glob:, prefix:, name_strip:, height: "h-24", grid_cols: "grid-cols-2 md:grid-cols-4", rounded: false)
      tag.div(class: "grid #{grid_cols} gap-6 mb-8") do
        safe_join(Dir.glob(Rails.root.join(glob)).sort.map do |path|
          ext = File.extname(path)
          name = File.basename(path, ext)
          tag.div(class: "text-center p-4 rounded-xl", style: "background-color: var(--base-bg-secondary);") do
            img_classes = rounded ? "w-full h-full object-cover" : "max-h-full w-auto"
            wrapper_class = rounded ? "#{height} w-24 mx-auto mb-3 rounded-full overflow-hidden" : "#{height} mx-auto mb-3 flex items-center justify-center"
            tag.div(class: wrapper_class) do
              image_tag("#{prefix}#{File.basename(path)}", class: img_classes)
            end +
            tag.p(name.gsub(name_strip, "").titleize, class: "shuby-caption")
          end
        end)
      end
    end
  end
end
