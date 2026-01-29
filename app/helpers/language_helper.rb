module LanguageHelper
  LANGUAGES = {
    "es-co": "Spanish (Columbia)",
    en: "English",
    fr: "French",
    it: "Italiano",
    nl: "Dutch"
  }

  MOTHER_TONGUE_LANGUAGES = {
    ar: "Arabic",
    bn: "Bengali",
    zh: "Chinese",
    nl: "Dutch",
    en: "English",
    fr: "French",
    de: "German",
    hi: "Hindi",
    it: "Italian",
    ja: "Japanese",
    ko: "Korean",
    pt: "Portuguese",
    ru: "Russian",
    es: "Spanish",
    tr: "Turkish",
    vi: "Vietnamese"
  }.freeze

  def language_options
    LANGUAGES.slice(*I18n.available_locales).invert.to_a
  end

  def mother_tongue_options
    MOTHER_TONGUE_LANGUAGES.map { |code, name|
      [t("languages.#{code}", default: name), name]
    }.sort_by(&:first)
  end
end
