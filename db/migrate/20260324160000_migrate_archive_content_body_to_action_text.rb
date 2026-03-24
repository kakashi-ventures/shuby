# frozen_string_literal: true

class MigrateArchiveContentBodyToActionText < ActiveRecord::Migration[8.0]
  def up
    # Copy existing body text into ActionText records
    execute <<~SQL
      INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
      SELECT 'body', body, 'ArchiveContent', id, NOW(), NOW()
      FROM archive_contents
      WHERE body IS NOT NULL AND body != ''
    SQL

    remove_column :archive_contents, :body
  end

  def down
    add_column :archive_contents, :body, :text

    # Best-effort restore: copy ActionText HTML back to the column
    execute <<~SQL
      UPDATE archive_contents
      SET body = (
        SELECT art.body FROM action_text_rich_texts art
        WHERE art.record_type = 'ArchiveContent'
          AND art.record_id = archive_contents.id
          AND art.name = 'body'
      )
    SQL

    execute <<~SQL
      DELETE FROM action_text_rich_texts
      WHERE record_type = 'ArchiveContent' AND name = 'body'
    SQL
  end
end
