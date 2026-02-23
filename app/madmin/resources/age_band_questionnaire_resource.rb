class AgeBandQuestionnaireResource < Madmin::Resource
  menu parent: "Resources", position: 3

  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :description, :text, index: false
  attribute :development_area
  attribute :min_age_months
  attribute :max_age_months
  attribute :version
  attribute :position
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations (hidden from show to avoid Madmin/Pagy compatibility issue)
  attribute :questions, form: false, index: false, show: false
  attribute :questionnaire_sessions, form: false, index: false, show: false

  def self.display_name(record)
    record.display_title
  end

  def self.default_sort_column
    "min_age_months"
  end

  def self.default_sort_direction
    "asc"
  end
end
