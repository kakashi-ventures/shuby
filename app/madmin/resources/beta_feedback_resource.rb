class BetaFeedbackResource < Madmin::Resource
  menu parent: "Beta"

  scope :unresolved
  scope :ordered

  attribute :id, form: false
  attribute :user, form: false
  attribute :account, form: false
  attribute :section, form: false
  attribute :page_url, form: false
  attribute :feedback_type, form: false
  attribute :description, form: false
  attribute :severity, form: false
  attribute :status
  attribute :admin_notes
  attribute :screenshot, index: false
  attribute :metadata, form: false, index: false
  attribute :created_at, form: false
  attribute :updated_at, form: false

  def self.display_name(record)
    "[#{record.feedback_type}] #{record.section_display_name} — #{record.description.truncate(50)}"
  end

  def self.default_sort_column
    "created_at"
  end

  def self.default_sort_direction
    "desc"
  end
end
