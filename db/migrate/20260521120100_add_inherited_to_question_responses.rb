class AddInheritedToQuestionResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :question_responses, :inherited, :boolean, default: false, null: false
    add_index :question_responses, :inherited
  end
end
