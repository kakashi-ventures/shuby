class CreateGrowthPhases < ActiveRecord::Migration[8.1]
  def change
    create_table :growth_phases do |t|
      t.integer :min_age_months, null: false, default: 0
      t.integer :max_age_months, null: false, default: 36
      t.string :title, null: false
      t.text :description, null: false
      t.string :illustration_key
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :growth_phases, [:min_age_months, :max_age_months]
  end
end
