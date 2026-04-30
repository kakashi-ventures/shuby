class AddBenefitsToArchiveContents < ActiveRecord::Migration[8.1]
  def change
    add_column :archive_contents, :benefits, :text, array: true, default: [], null: false
  end
end
