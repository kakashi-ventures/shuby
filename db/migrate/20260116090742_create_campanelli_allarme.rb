class CreateCampanelliAllarme < ActiveRecord::Migration[8.1]
  def change
    create_table :campanelli_allarme do |t|
      t.integer :month, null: false
      t.text :description, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :campanelli_allarme, [:month, :position]
  end
end
