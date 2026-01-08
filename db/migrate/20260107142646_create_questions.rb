class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :age_band_questionnaire, null: false, foreign_key: true
      t.text :prompt, null: false
      t.text :help_text
      t.integer :position, null: false, default: 0
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :questions, [:age_band_questionnaire_id, :position]
  end
end
