# frozen_string_literal: true

module DesignSystem
  module TypographyHelper
    TYPOGRAPHY_SPECIMENS = [
      {label: "Display / XL - Large Overlay Titles (Figma: Headings/H1)", css_class: "shuby-display-xl",
       sample: "Tappa completata!", spec: "Baloo 2 Bold \u2022 38px \u2022 Line-height 1"},
      {label: "Display / D1 - Hero Text (Figma: Font Primario)", css_class: "shuby-d1",
       sample: "Il tempo speciale con il tuo bambino", spec: "Baloo 2 Bold \u2022 28px \u2022 Line-height 34px"},
      {label: "Display / D2 - Card Titles (Figma: Display/D2)", css_class: "shuby-d2",
       sample: "Comunicazione e linguaggio", spec: "Baloo 2 Bold \u2022 20px \u2022 Line-height 24px"},
      {label: "Heading / H1 - Page Title", css_class: "shuby-h1",
       sample: "Gestione", spec: "Montserrat Bold \u2022 24px \u2022 Line-height 30px"},
      {label: "Heading / H2 - Section Title", css_class: "shuby-h2",
       sample: "Impostazioni", spec: "Montserrat Semibold \u2022 20px \u2022 Line-height 26px"},
      {label: "Body / P1 - Main Text (Figma: Body/P1/Light)", css_class: "shuby-p1",
       sample: "Un dono reciproco di attenzione esclusiva che nutre la connessione genitore-bambino e sostiene lo sviluppo emotivo.",
       spec: "Montserrat Regular \u2022 14px \u2022 Line-height 150%"},
      {label: "Caption / Span / Dark - Emphasized Labels (Figma: Caption/Span/Dark)", css_class: "shuby-caption-dark",
       sample: "RICORDA:", spec: "Montserrat Semi-Bold \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"},
      {label: "Caption / Overline - Labels (Figma: Overline/OL/Light)", css_class: "shuby-overline",
       sample: "0\u201336 MESI", spec: "Montserrat Regular \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"}
    ].freeze

    def ds_typography_specimen(label:, css_class:, sample:, spec:)
      tag.div(class: "shuby-card mb-6") do
        tag.p(label, class: "shuby-caption mb-2") +
          tag.p(sample, class: css_class) +
          tag.p(spec, class: "shuby-p2 mt-2")
      end
    end
  end
end
