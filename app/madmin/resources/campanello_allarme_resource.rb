class CampanelloAllarmeResource < Madmin::Resource
  menu parent: "Resources", position: 5

  # Scopes for filtering by month
  scope :ordered

  # Attributes
  attribute :id, form: false
  attribute :month
  attribute :description, :text
  attribute :position
  attribute :created_at, form: false
  attribute :updated_at, form: false

  def self.display_name(record)
    "Mese #{record.month}: #{record.description.truncate(50)}"
  end

  def self.default_sort_column
    "month"
  end

  def self.default_sort_direction
    "asc"
  end
end
