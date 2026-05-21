class BetaFeedbackResource < Madmin::Resource
  menu parent: "Beta"

  scope :unresolved
  scope :ordered

  attribute :id, form: false
  attribute :user, form: false
  attribute :account, form: false, index: true
  attribute :section, form: false, index: true
  attribute :page_url, form: false
  attribute :feedback_type, form: false, index: true
  attribute :description, form: false, index: true
  attribute :severity, form: false, index: true
  attribute :status, index: true
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
