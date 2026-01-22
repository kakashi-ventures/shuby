class AddQuestionnaireVersionToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :questionnaire_sessions, :questionnaire_version, :integer
    add_index :questionnaire_sessions, :questionnaire_version
  end
end
