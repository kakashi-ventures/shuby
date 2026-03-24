class AddIllustrationKeyToQuestionsAndDevelopmentAreas < ActiveRecord::Migration[8.1]
  def change
    add_column :questions, :illustration_key, :string
    add_column :development_areas, :illustration_key, :string

    add_index :questions, :illustration_key, unique: true
    add_index :development_areas, :illustration_key, unique: true
  end
end
