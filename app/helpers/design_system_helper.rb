module DesignSystemHelper
  COLOR_SCALES = {
    "Primary Blue Scale" => {
      grid_cols: "grid-cols-2 md:grid-cols-4 lg:grid-cols-6",
      colors: [
        {css_var: "--color-shuby-blue-50", label: "Blue 50", hex: "#F0F7FF"},
        {css_var: "--color-shuby-blue-100", label: "Blue 100", hex: "#D4EDFF"},
        {css_var: "--color-shuby-blue-300", label: "Blue 300", hex: "#E5F2FF"},
        {css_var: "--color-shuby-blue-500", label: "Blue 500", hex: "#9EC6F0"},
        {css_var: "--color-shuby-blue-700", label: "Blue 700", hex: "#3B83CF"},
        {css_var: "--color-shuby-blue-800", label: "Blue 800", hex: "#0159B5"}
      ]
    },
    "Verde (Green/Teal) Scale" => {
      grid_cols: "grid-cols-2 md:grid-cols-3 lg:grid-cols-6",
      colors: [
        {css_var: "--color-shuby-verde-100", label: "Verde 100", hex: "#E0F7F7"},
        {css_var: "--color-shuby-verde-200", label: "Verde 200", hex: "#D1F8F9"},
        {css_var: "--color-shuby-verde-300", label: "Verde 300", hex: "#99E0E2"},
        {css_var: "--color-shuby-verde-400", label: "Verde 400", hex: "#7DCBCD"},
        {css_var: "--color-shuby-verde-500", label: "Verde 500", hex: "#38A3A5"},
        {css_var: "--color-shuby-verde-600", label: "Verde 600", hex: "#2C9A94"}
      ]
    },
    "Verde Scuro (Dark Teal) Scale" => {
      grid_cols: "grid-cols-2 md:grid-cols-4",
      colors: [
        {css_var: "--color-shuby-verde-scuro-400", label: "Verde Scuro 400", hex: "#37A3C1"},
        {css_var: "--color-shuby-verde-scuro-500", label: "Verde Scuro 500", hex: "#007FA3"}
      ]
    },
    "Status Colors" => {
      grid_cols: "grid-cols-2 md:grid-cols-4",
      colors: [
        {css_var: "--color-shuby-green-500", label: "Success Green", hex: "#2ECC71"},
        {css_var: "--color-shuby-orange-500", label: "Warning Orange", hex: "#F39C12"},
        {css_var: "--color-shuby-red-500", label: "Danger Red", hex: "#E74C3C"},
        {css_var: "--color-shuby-giallo-400", label: "Giallo 400", hex: "#FFF7D4"},
        {css_var: "--color-shuby-giallo-500", label: "Giallo 500", hex: "#FFE882"}
      ]
    },
    "Fucsia Scale" => {
      grid_cols: "grid-cols-2 md:grid-cols-4",
      colors: [
        {css_var: "--color-shuby-fucsia-500", label: "Fucsia 500", hex: "#C500A2"},
        {css_var: "--color-shuby-fucsia-700", label: "Fucsia 700", hex: "#91018A"}
      ]
    },
    "Magenta/Pink Scale (Selection)" => {
      grid_cols: "grid-cols-2 md:grid-cols-4 lg:grid-cols-6",
      colors: [
        {css_var: "--color-shuby-magenta-50", label: "Magenta 50", hex: "#FDF4FF"},
        {css_var: "--color-shuby-magenta-100", label: "Magenta 100", hex: "#FAE8FF"},
        {css_var: "--color-shuby-magenta-400", label: "Magenta 400", hex: "#E879F9"},
        {css_var: "--color-shuby-magenta-500", label: "Magenta 500", hex: "#D946EF"},
        {css_var: "--color-shuby-magenta-600", label: "Magenta 600", hex: "#C026D3"},
        {css_var: "--color-shuby-purple-300", label: "Purple 300", hex: "#A5B4FC"}
      ]
    },
    "Neutrals (Figma Colori/Grigio)" => {
      grid_cols: "grid-cols-2 md:grid-cols-6",
      colors: [
        {css_var: "--color-shuby-white", label: "White", hex: "#FFFFFF", border: true},
        {css_var: "--color-shuby-gray-400", label: "Gray 400", hex: "#F6F8FA"},
        {css_var: "--color-shuby-gray-500", label: "Gray 500", hex: "#E2E5E8"},
        {css_var: "--color-shuby-gray-700", label: "Gray 700", hex: "#898D91"},
        {css_var: "--color-shuby-gray-800", label: "Gray 800", hex: "#616467"},
        {css_var: "--color-shuby-black", label: "Black", hex: "#000000"}
      ]
    }
  }.freeze

  TYPOGRAPHY_SPECIMENS = [
    {label: "Display / XL - Large Overlay Titles (Figma: Headings/H1)", css_class: "shuby-display-xl",
     sample: "Tappa completata!", spec: "Baloo 2 Bold • 38px • Line-height 1"},
    {label: "Display / D1 - Hero Text (Figma: Font Primario)", css_class: "shuby-d1",
     sample: "Il tempo speciale con il tuo bambino", spec: "Baloo 2 Bold • 28px • Line-height 34px"},
    {label: "Display / D2 - Card Titles (Figma: Display/D2)", css_class: "shuby-d2",
     sample: "Comunicazione e linguaggio", spec: "Baloo 2 Bold • 20px • Line-height 24px"},
    {label: "Heading / H1 - Page Title", css_class: "shuby-h1",
     sample: "Gestione", spec: "Montserrat Bold • 24px • Line-height 30px"},
    {label: "Heading / H2 - Section Title", css_class: "shuby-h2",
     sample: "Impostazioni", spec: "Montserrat Semibold • 20px • Line-height 26px"},
    {label: "Body / P1 - Main Text (Figma: Body/P1/Light)", css_class: "shuby-p1",
     sample: "Un dono reciproco di attenzione esclusiva che nutre la connessione genitore-bambino e sostiene lo sviluppo emotivo.",
     spec: "Montserrat Regular • 14px • Line-height 150%"},
    {label: "Caption / Span / Dark - Emphasized Labels (Figma: Caption/Span/Dark)", css_class: "shuby-caption-dark",
     sample: "RICORDA:", spec: "Montserrat Semi-Bold • 10px • Uppercase • Line-height 1.5"},
    {label: "Caption / Overline - Labels (Figma: Overline/OL/Light)", css_class: "shuby-overline",
     sample: "0–36 MESI", spec: "Montserrat Regular • 10px • Uppercase • Line-height 1.5"}
  ].freeze

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

  def ds_color_swatch(css_var:, label:, hex:, border: false)
    tag.div(class: "text-center") do
      tag.div("", class: "w-full h-16 rounded-lg mb-2#{" border" if border}",
        style: "background-color: var(#{css_var});#{" border-color: var(--base-border-tertiary);" if border}") +
        tag.p(label, class: "shuby-caption") +
        tag.p(hex, class: "shuby-p2")
    end
  end

  def ds_color_scale(title:, colors:, grid_cols: "grid-cols-2 md:grid-cols-4 lg:grid-cols-6")
    tag.h3(title, class: "shuby-h3 mb-4") +
      tag.div(class: "grid #{grid_cols} gap-4 mb-8") do
        safe_join(colors.map { |c| ds_color_swatch(**c) })
      end
  end

  def ds_typography_specimen(label:, css_class:, sample:, spec:)
    tag.div(class: "shuby-card mb-6") do
      tag.p(label, class: "shuby-caption mb-2") +
        tag.p(sample, class: css_class) +
        tag.p(spec, class: "shuby-p2 mt-2")
    end
  end

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
