module GeoDataHelper
  def country_options
    ::ISO3166::Country.all.map do |country|
      name = country.translations[I18n.locale.to_s] || country.common_name
      [name, name]
    end.sort_by(&:first)
  end

  def nationality_options
    ::ISO3166::Country.all.filter_map do |country|
      nationality = country.nationality
      [nationality, nationality] if nationality.present?
    end.sort_by(&:first).uniq(&:first)
  end
end
