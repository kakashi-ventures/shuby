class AddNicknameToChildren < ActiveRecord::Migration[8.1]
  def change
    add_column :children, :nickname, :string
    change_column_null :children, :name, true
  end
end
