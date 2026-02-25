# frozen_string_literal: true

# Formally adds account_id to shuby_chats for multi-tenancy scoping.
# The column already exists in the database (added manually) so we
# use if_not_exists guards to make this migration idempotent.
class AddAccountIdToShubyChats < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:shuby_chats, :account_id)
      add_reference :shuby_chats, :account, null: false, foreign_key: true
    end
  end
end
