class AddContentKeyToQuestions < ActiveRecord::Migration[8.0]
  def up
    add_column :questions, :content_key, :string
    add_index :questions, :content_key

    say_with_time "Backfilling content_key from normalized prompts" do
      Question.reset_column_information
      Question.find_each do |q|
        q.update_column(:content_key, Question.normalize_prompt(q.prompt))
      end
    end
  end

  def down
    remove_index :questions, :content_key
    remove_column :questions, :content_key
  end
end
