class CreateQuestionResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :question_responses do |t|
      t.references :questionnaire_session, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :answer, null: false, default: 0
      t.text :notes
      t.timestamps
    end

    add_index :question_responses, [:questionnaire_session_id, :question_id],
              unique: true, name: "idx_responses_session_question"
  end
end
