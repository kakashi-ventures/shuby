class CreateDevelopmentAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :development_areas do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :icon
      t.string :color
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :development_areas, :slug, unique: true
    add_index :development_areas, :position
  end
end
