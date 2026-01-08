class CreateAgeBandQuestionnaires < ActiveRecord::Migration[8.1]
  def change
    create_table :age_band_questionnaires do |t|
      t.references :development_area, null: false, foreign_key: true
      t.integer :min_age_months, null: false
      t.integer :max_age_months, null: false
      t.string :title
      t.text :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :age_band_questionnaires, [:development_area_id, :min_age_months],
              unique: true, name: "idx_questionnaires_area_age"
    add_index :age_band_questionnaires, [:min_age_months, :max_age_months]
  end
end
