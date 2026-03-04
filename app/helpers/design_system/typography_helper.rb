# frozen_string_literal: true

module DesignSystem
  module TypographyHelper
    TYPOGRAPHY_SPECIMENS = [
      # Display
      {label: "D1 \u2014 Hero, testi grandi (Figma: Display/D1)", css_class: "shuby-d1",
       sample: "Tappa completata!", spec: "Baloo 2 Bold \u2022 48px \u2022 Line-height 1"},
      {label: "D2 \u2014 Titoli card (Figma: Display/D2)", css_class: "shuby-d2",
       sample: "Comunicazione e linguaggio", spec: "Baloo 2 Bold \u2022 20px \u2022 Line-height 1.2"},
      # Headings
      {label: "H1 \u2014 Titolo pagina (Figma: Headings/H1)", css_class: "shuby-h1",
       sample: "Il tempo speciale con il tuo bambino", spec: "Baloo 2 Bold \u2022 38px \u2022 Line-height 1"},
      {label: "H2 \u2014 Titolo sezione (Figma: Headings/H2)", css_class: "shuby-h2",
       sample: "Gestione", spec: "Baloo 2 Bold \u2022 28px \u2022 Line-height 1"},
      {label: "H3 \u2014 Titolo in card, blocchi secondari (Figma: Headings/H3)", css_class: "shuby-h3",
       sample: "Impostazioni", spec: "Montserrat Semi-Bold \u2022 20px \u2022 Line-height 1.5"},
      # Body
      {label: "P1 / Light \u2014 Testo principale, paragrafi (Figma: Body/P1/Light)", css_class: "shuby-p1",
       sample: "Un dono reciproco di attenzione esclusiva che nutre la connessione genitore-bambino e sostiene lo sviluppo emotivo.",
       spec: "Montserrat Regular \u2022 14px \u2022 Line-height 150%"},
      {label: "P1 / Dark \u2014 Testo principale, paragrafi (Figma: Body/P1/Dark)", css_class: "shuby-p1-dark",
       sample: "Un dono reciproco di attenzione esclusiva che nutre la connessione genitore-bambino e sostiene lo sviluppo emotivo.",
       spec: "Montserrat Semi-Bold \u2022 14px \u2022 Line-height 150%"},
      {label: "P2 / Light \u2014 Testo descrittivo, form (Figma: Body/P2/Light)", css_class: "shuby-p2",
       sample: "Dettagli aggiuntivi e note informative per il genitore.", spec: "Montserrat Regular \u2022 12px \u2022 Line-height 150%"},
      {label: "P2 / Dark \u2014 Testo descrittivo, form (Figma: Body/P2/Dark)", css_class: "shuby-p2-dark",
       sample: "Dettagli aggiuntivi e note informative per il genitore.", spec: "Montserrat Semi-Bold \u2022 12px \u2022 Line-height 150%"},
      # Caption / Span
      {label: "Span / Light \u2014 Microtesto, date, etichette (Figma: Caption/Span/Light)", css_class: "shuby-caption",
       sample: "RICORDA:", spec: "Montserrat Medium \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"},
      {label: "Span / Dark \u2014 Microtesto, date, etichette (Figma: Caption/Span/Dark)", css_class: "shuby-caption-dark",
       sample: "RICORDA:", spec: "Montserrat Semi-Bold \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"},
      # Overline
      {label: "OL / Light \u2014 Tag, badge, label in pillole (Figma: Overline/OL/Light)", css_class: "shuby-overline",
       sample: "0\u201336 MESI", spec: "Montserrat Regular \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"},
      {label: "OL / Dark \u2014 Tag, badge, label in pillole (Figma: Overline/OL/Dark)", css_class: "shuby-overline-dark",
       sample: "0\u201336 MESI", spec: "Montserrat Semi-Bold \u2022 10px \u2022 Uppercase \u2022 Line-height 1.5"},
      # Buttons
      {label: "Button L \u2014 Testo nei pulsanti grandi (Figma: Button/Button L)", css_class: "shuby-btn-text-l",
       sample: "Inizia il questionario", spec: "Montserrat Semi-Bold \u2022 20px \u2022 Line-height 1.5"},
      {label: "Button S \u2014 Testo nei pulsanti piccoli (Figma: Button/Button S)", css_class: "shuby-btn-text-s",
       sample: "Salva misurazione", spec: "Montserrat Semi-Bold \u2022 16px \u2022 Line-height 1.5"}
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
