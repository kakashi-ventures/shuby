class AddUncertainLabelToQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :questions, :uncertain_label, :string
  end
end
