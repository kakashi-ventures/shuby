class CreateFamilyProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :family_profiles do |t|
      t.references :account, null: false, foreign_key: true, index: {unique: true}

      # Location & cultural background
      t.string :country
      t.string :nationality
      t.string :mother_tongue

      # Family structure
      t.integer :family_structure, default: 0
      t.integer :two_parents_type

      # Household info
      t.integer :number_of_children, default: 1
      t.integer :languages_spoken_at_home, default: 1

      # Primary caregivers (stored as array/jsonb)
      t.jsonb :primary_caregivers, default: []

      # Family health history
      t.boolean :has_hereditary_conditions
      t.jsonb :hereditary_conditions, default: []

      t.timestamps
    end
  end
end
