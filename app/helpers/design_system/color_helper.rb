# frozen_string_literal: true

module DesignSystem
  module ColorHelper
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
  end
end
