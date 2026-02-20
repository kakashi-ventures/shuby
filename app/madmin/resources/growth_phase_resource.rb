class GrowthPhaseResource < Madmin::Resource
  menu parent: "Resources", position: 7

  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :description, :text, index: false
  attribute :min_age_months
  attribute :max_age_months
  attribute :illustration_key
  attribute :position
  attribute :created_at, form: false
  attribute :updated_at, form: false

  def self.display_name(record)
    record.title
  end

  def self.default_sort_column
    "min_age_months"
  end

  def self.default_sort_direction
    "asc"
  end
end
