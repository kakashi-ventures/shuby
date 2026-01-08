class CreateQuestionnaireSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :questionnaire_sessions do |t|
      t.references :child, null: false, foreign_key: true
      t.references :age_band_questionnaire, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :child_age_months
      t.text :notes
      t.timestamps
    end

    add_index :questionnaire_sessions, [:child_id, :age_band_questionnaire_id, :created_at],
              name: "idx_sessions_child_questionnaire_time"
    add_index :questionnaire_sessions, [:child_id, :status]
  end
end
