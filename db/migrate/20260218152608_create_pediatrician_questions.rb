class CreatePediatricianQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :pediatrician_questions do |t|
      t.references :child, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end
  end
end
