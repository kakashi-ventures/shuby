class QuestionResource < Madmin::Resource
  menu parent: "Sviluppo e Questionari", label: "❓ Domande", position: 3

  scope :active

  # Attributes
  attribute :id, form: false
  attribute :prompt, :text
  attribute :help_text, :text, index: false
  attribute :age_band_questionnaire
  attribute :position
  attribute :active, :boolean
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations (hidden from show to avoid Madmin/Pagy compatibility issue)
  attribute :question_responses, form: false, index: false, show: false

  def self.display_name(record)
    record.prompt.truncate(60)
  end

  def self.default_sort_column
    "id"
  end

  def self.default_sort_direction
    "asc"
  end
end
