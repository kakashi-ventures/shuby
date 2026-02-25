# frozen_string_literal: true

# Links each ShubyChat to the specific child being discussed.
# Previously, child_context_prompt always picked the first child alphabetically,
# ignoring the user's current child selection.
class AddChildIdToShubyChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :shuby_chats, :child, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE shuby_chats
          SET child_id = (
            SELECT children.id FROM children
            WHERE children.account_id = shuby_chats.account_id
              AND children.active = TRUE
            ORDER BY children.name ASC
            LIMIT 1
          )
        SQL
      end
    end
  end
end
