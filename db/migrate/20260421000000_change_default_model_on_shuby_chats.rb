class ChangeDefaultModelOnShubyChats < ActiveRecord::Migration[8.1]
  def change
    change_column_default :shuby_chats, :model, from: "gpt-5-mini", to: "gpt-5.4-mini"
  end
end
