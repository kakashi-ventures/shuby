# frozen_string_literal: true

class AddSpecialistToArchiveContents < ActiveRecord::Migration[8.1]
  def change
    add_column :archive_contents, :specialist, :boolean, default: false, null: false
    add_index :archive_contents, [:content_type, :specialist, :published]
  end
end
