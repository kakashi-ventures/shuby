class ArchiveContentResource < Madmin::Resource
  menu parent: "Resources", position: 1

  # Scopes for filtering
  scope :published
  scope :draft
  scope :articles
  scope :books
  scope :games
  scope :tips

  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :slug, form: false
  attribute :description, index: false
  attribute :body, :text, index: false
  attribute :content_type, :select, collection: ArchiveContent.content_types.keys
  attribute :category
  attribute :min_age_months
  attribute :max_age_months

  # Book-specific fields
  attribute :author, index: false
  attribute :illustrator, index: false
  attribute :publisher, index: false
  attribute :publication_year, index: false
  attribute :isbn, index: false

  # Game-specific fields
  attribute :duration_minutes, index: false
  attribute :materials, index: false

  # Publishing
  attribute :published, :boolean
  attribute :published_at
  attribute :position

  # Attachment
  attribute :cover_image, index: false

  # Timestamps
  attribute :created_at, form: false
  attribute :updated_at, form: false

  def self.display_name(record)
    record.title
  end

  def self.default_sort_column
    "position"
  end

  def self.default_sort_direction
    "asc"
  end

  member_action do
    link_to "View", main_app.archive_path(@record.slug), class: "btn btn-secondary"
  end
end
