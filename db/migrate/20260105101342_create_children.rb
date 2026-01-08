class CreateChildren < ActiveRecord::Migration[8.1]
  def change
    create_table :children do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.date :birth_date, null: false
      t.integer :sex, default: 0
      t.integer :gestational_weeks
      t.integer :gestational_days
      t.text :notes
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :children, [:account_id, :active]
  end
end
