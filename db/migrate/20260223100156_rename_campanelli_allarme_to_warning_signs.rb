class RenameCampanelliAllarmeToWarningSigns < ActiveRecord::Migration[8.1]
  def change
    rename_table :campanelli_allarme, :warning_signs if table_exists?(:campanelli_allarme)
  end
end
