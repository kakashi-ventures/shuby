class DevelopmentAreaResource < Madmin::Resource
  menu parent: "Resources", position: 2

  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :slug
  attribute :color
  attribute :icon
  attribute :position
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations (hidden from show to avoid Madmin/Pagy compatibility issue)
  attribute :age_band_questionnaires, form: false, index: false, show: false

  def self.display_name(record)
    record.name
  end

  def self.default_sort_column
    "position"
  end

  def self.default_sort_direction
    "asc"
  end
end
