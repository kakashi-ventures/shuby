# frozen_string_literal: true

# Adds account_id to shuby_chats for multi-tenancy scoping.
# Handles both cases:
#   - Column already exists (added manually on some environments)
#   - Column does not exist (production) — adds nullable, backfills, then enforces NOT NULL
class AddAccountIdToShubyChats < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:shuby_chats, :account_id)
      add_reference :shuby_chats, :account, null: true, foreign_key: true

      # Backfill: assign each chat to the user's personal account
      execute <<~SQL
        UPDATE shuby_chats
        SET account_id = (
          SELECT accounts.id FROM accounts
          INNER JOIN account_users ON account_users.account_id = accounts.id
          WHERE account_users.user_id = shuby_chats.user_id
            AND accounts.personal = TRUE
          LIMIT 1
        )
      SQL

      change_column_null :shuby_chats, :account_id, false
    end
  end

  def down
    remove_reference :shuby_chats, :account, foreign_key: true if column_exists?(:shuby_chats, :account_id)
  end
end
