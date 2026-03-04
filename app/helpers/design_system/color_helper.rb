# frozen_string_literal: true

module DesignSystem
  module ColorHelper
    COLOR_SCALES = {
      "Blu Scale (Figma: Colori/Blu)" => {
        grid_cols: "grid-cols-2 md:grid-cols-3 lg:grid-cols-6",
        colors: [
          {css_var: "--color-shuby-blue-300", label: "Blu 300", hex: "#E5F2FF"},
          {css_var: "--color-shuby-blue-400", label: "Blu 400", hex: "#CAE4FF"},
          {css_var: "--color-shuby-blue-500", label: "Blu 500", hex: "#9EC6F0"},
          {css_var: "--color-shuby-blue-600", label: "Blu 600", hex: "#6BA2DC"},
          {css_var: "--color-shuby-blue-700", label: "Blu 700", hex: "#3B83CF"},
          {css_var: "--color-shuby-blue-800", label: "Blu 800", hex: "#0159B5"}
        ]
      },
      "Verde Scale (Figma: Colori/Verde)" => {
        grid_cols: "grid-cols-2 md:grid-cols-4",
        colors: [
          {css_var: "--color-shuby-verde-200", label: "Verde 200", hex: "#D1F8F9"},
          {css_var: "--color-shuby-verde-300", label: "Verde 300", hex: "#99E0E2"},
          {css_var: "--color-shuby-verde-400", label: "Verde 400", hex: "#7DCBCD"},
          {css_var: "--color-shuby-verde-500", label: "Verde 500", hex: "#38A3A5"}
        ]
      },
      "Verde Scuro Scale (Figma: Colori/Verde Scuro)" => {
        grid_cols: "grid-cols-2 md:grid-cols-4",
        colors: [
          {css_var: "--color-shuby-verde-scuro-400", label: "Verde Scuro 400", hex: "#37A3C1"},
          {css_var: "--color-shuby-verde-scuro-500", label: "Verde Scuro 500", hex: "#007FA3"}
        ]
      },
      "Giallo Scale (Figma: Colori/Giallo)" => {
        grid_cols: "grid-cols-2 md:grid-cols-4",
        colors: [
          {css_var: "--color-shuby-giallo-400", label: "Giallo 400", hex: "#FFF7D4"},
          {css_var: "--color-shuby-giallo-500", label: "Giallo 500", hex: "#FFE882"},
          {css_var: "--color-shuby-giallo-600", label: "Giallo 600", hex: "#FDD318"}
        ]
      },
      "Status Colors" => {
        grid_cols: "grid-cols-2 md:grid-cols-4",
        colors: [
          {css_var: "--color-shuby-green-500", label: "Success Green", hex: "#2ECC71"},
          {css_var: "--color-shuby-orange-500", label: "Warning Orange", hex: "#F39C12"},
          {css_var: "--color-shuby-red-500", label: "Danger Red", hex: "#E74C3C"}
        ]
      },
      "Fucsia Scale" => {
        grid_cols: "grid-cols-2 md:grid-cols-4",
        colors: [
          {css_var: "--color-shuby-fucsia-300", label: "Fucsia 300", hex: "#F456D8"},
          {css_var: "--color-shuby-fucsia-400", label: "Fucsia 400", hex: "#DC21BB"},
          {css_var: "--color-shuby-fucsia-500", label: "Fucsia 500", hex: "#C500A2"},
          {css_var: "--color-shuby-fucsia-600", label: "Fucsia 600", hex: "#AB008D"},
          {css_var: "--color-shuby-fucsia-700", label: "Fucsia 700", hex: "#91018A"}
        ]
      },
      "Magenta Scale (Figma: Colori/Magenta)" => {
        grid_cols: "grid-cols-2 md:grid-cols-4 lg:grid-cols-5",
        colors: [
          {css_var: "--color-shuby-magenta-300", label: "Magenta 300", hex: "#FF92D9"},
          {css_var: "--color-shuby-magenta-400", label: "Magenta 400", hex: "#FF56C4"},
          {css_var: "--color-shuby-magenta-500", label: "Magenta 500", hex: "#FD1EAF"},
          {css_var: "--color-shuby-magenta-600", label: "Magenta 600", hex: "#E11097"},
          {css_var: "--color-shuby-magenta-700", label: "Magenta 700", hex: "#BF007C"}
        ]
      },
      "Neutrals (Figma Colori/Grigio)" => {
        grid_cols: "grid-cols-2 md:grid-cols-6",
        colors: [
          {css_var: "--color-shuby-white", label: "White", hex: "#FFFFFF", border: true},
          {css_var: "--color-shuby-gray-400", label: "Gray 400", hex: "#F6F8FA"},
          {css_var: "--color-shuby-gray-500", label: "Gray 500", hex: "#E2E5E8"},
          {css_var: "--color-shuby-gray-600", label: "Gray 600", hex: "#B5B7BA"},
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
