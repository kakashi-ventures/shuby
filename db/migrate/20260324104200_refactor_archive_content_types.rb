# frozen_string_literal: true

# Refactor content_type enum: article(0), book(1), game(2), tip(3)
# becomes: article(0), tip(1), activity(2)
#
# - book(1) → tip(1): same integer, set category "Lettura" if blank
# - game(2) with category "Giochi" → tip(1)
# - game(2) with other categories → activity(2): same integer
# - tip(3) → tip(1): integer changes
class RefactorArchiveContentTypes < ActiveRecord::Migration[8.1]
  def up
    # Books (1) → tip (1). Same integer; ensure category is set
    execute <<~SQL
      UPDATE archive_contents SET category = 'Lettura'
      WHERE content_type = 1 AND (category IS NULL OR category = '')
    SQL

    # Games with "Giochi" category → tip (1)
    execute <<~SQL
      UPDATE archive_contents SET content_type = 1
      WHERE content_type = 2 AND category = 'Giochi'
    SQL

    # Remaining games (2) → activity (2) — same integer, no SQL needed

    # Old tips (3) → new tip (1)
    execute <<~SQL
      UPDATE archive_contents SET content_type = 1
      WHERE content_type = 3
    SQL
  end

  def down
    # Approximate reverse using category to infer original type
    # Tips with general categories → old tip (3)
    execute <<~SQL
      UPDATE archive_contents SET content_type = 3
      WHERE content_type = 1 AND category NOT IN ('Lettura', 'Giochi')
    SQL

    # Tips with "Giochi" category → old game (2)
    execute <<~SQL
      UPDATE archive_contents SET content_type = 2
      WHERE content_type = 1 AND category = 'Giochi'
    SQL

    # book(1) and game-as-activity(2) keep their integers — already correct
  end
end
