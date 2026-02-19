class AddOrderedIndexToMeasurements < ActiveRecord::Migration[8.1]
  def change
    add_index :measurements,
              [:child_id, :measurement_type, :measured_at],
              order: {measured_at: :desc},
              name: "idx_measurements_child_type_date_desc"
  end
end
