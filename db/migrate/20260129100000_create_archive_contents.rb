# frozen_string_literal: true

class CreateArchiveContents < ActiveRecord::Migration[8.1]
  def change
    create_table :archive_contents do |t|
      # Content identification
      t.string :title, null: false
      t.text :description
      t.text :body
      t.integer :content_type, null: false, default: 0
      t.string :category
      t.string :slug, null: false

      # Age targeting (0-36 months)
      t.integer :min_age_months, default: 0
      t.integer :max_age_months, default: 36

      # Book-specific fields
      t.string :author
      t.string :illustrator
      t.string :publisher
      t.integer :publication_year
      t.string :isbn

      # Game/Activity-specific fields
      t.integer :duration_minutes
      t.string :materials

      # Publishing
      t.boolean :published, default: false
      t.datetime :published_at
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :archive_contents, :slug, unique: true
    add_index :archive_contents, :content_type
    add_index :archive_contents, [:min_age_months, :max_age_months]
    add_index :archive_contents, [:content_type, :published]
    add_index :archive_contents, :category
    add_index :archive_contents, :position
  end
end
