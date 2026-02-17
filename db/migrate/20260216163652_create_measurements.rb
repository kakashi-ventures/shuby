# frozen_string_literal: true

class CreateMeasurements < ActiveRecord::Migration[8.1]
  def change
    create_table :measurements do |t|
      t.references :child, null: false, foreign_key: true
      t.integer :measurement_type, null: false
      t.decimal :value, precision: 8, scale: 2, null: false
      t.datetime :measured_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.text :notes
      t.integer :percentile

      t.timestamps
    end

    add_index :measurements, [:child_id, :measurement_type, :measured_at],
              name: "idx_measurements_child_type_date"
  end
end
