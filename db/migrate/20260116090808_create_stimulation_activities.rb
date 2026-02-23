class CreateStimulationActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :stimulation_activities do |t|
      t.integer :month, null: false
      t.text :description, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :stimulation_activities, [:month, :position]
  end
end
