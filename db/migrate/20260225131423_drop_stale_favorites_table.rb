class DropStaleFavoritesTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :favorites, if_exists: true
  end

  def down
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :archive_content, null: false, foreign_key: true
      t.timestamps
    end
    add_index :favorites, [:user_id, :archive_content_id], unique: true
  end
end
