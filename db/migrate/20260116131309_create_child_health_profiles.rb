class CreateChildHealthProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :child_health_profiles do |t|
      t.references :child, null: false, foreign_key: true, index: {unique: true}

      # Multiple birth info
      t.boolean :is_multiple_birth, default: false

      # Birth details - gestational age categories
      t.integer :gestational_age_category
      t.integer :birth_weight_grams

      # Pregnancy type
      t.integer :pregnancy_type

      # Post-birth hospitalization
      t.integer :hospitalized_after_birth

      # Birth complications (stored as array)
      t.jsonb :birth_complications, default: []

      # === PREMATURE MODULE (only if GA < 37 weeks) ===
      t.integer :birth_weight_under_1500
      t.integer :required_oxygen_ventilation
      t.jsonb :scheduled_followups, default: []

      # === Screening & Health ===
      t.integer :hearing_screening_result
      t.integer :vision_screening_result

      # === Feeding ===
      t.integer :current_feeding_type
      t.boolean :started_complementary_feeding, default: false
      t.date :complementary_feeding_start_date
      t.text :main_foods_introduced
      t.text :feeding_difficulties

      # === Sleep & Activity ===
      t.decimal :average_sleep_hours, precision: 4, scale: 1
      t.jsonb :sleep_quality_issues, default: []
      t.integer :floor_play_minutes_per_day

      t.timestamps
    end
  end
end
