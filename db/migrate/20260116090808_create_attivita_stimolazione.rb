class CreateAttivitaStimolazione < ActiveRecord::Migration[8.1]
  def change
    create_table :attivita_stimolazione do |t|
      t.integer :month, null: false
      t.text :description, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :attivita_stimolazione, [:month, :position]
  end
end
