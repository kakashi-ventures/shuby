class AddVersionToAgeBandQuestionnaires < ActiveRecord::Migration[8.1]
  def change
    add_column :age_band_questionnaires, :version, :integer, default: 1, null: false
    add_index :age_band_questionnaires, :version
    
    # Set version 1 for all existing questionnaires
    reversible do |dir|
      dir.up do
        AgeBandQuestionnaire.update_all(version: 1)
      end
    end
  end
end
