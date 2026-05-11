# frozen_string_literal: true

class CreateTimelineStageContents < ActiveRecord::Migration[8.1]
  def change
    create_table :timeline_stage_contents do |t|
      t.string :pill_key, null: false
      t.text :description, null: false
      t.text :suggestions
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :timeline_stage_contents, :pill_key, unique: true
  end
end
