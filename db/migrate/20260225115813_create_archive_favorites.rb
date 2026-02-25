class CreateArchiveFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :archive_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :archive_content, null: false, foreign_key: true
      t.timestamps
    end
    add_index :archive_favorites, [:user_id, :archive_content_id], unique: true
  end
end
