# frozen_string_literal: true

class CreateDashboardStageContents < ActiveRecord::Migration[8.1]
  def change
    create_table :dashboard_stage_contents do |t|
      t.string :kind, null: false
      t.integer :min_age_weeks
      t.integer :max_age_weeks
      t.integer :min_age_months
      t.integer :max_age_months
      t.string :label, null: false
      t.text :body, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :dashboard_stage_contents, [:kind, :min_age_weeks, :max_age_weeks],
      name: :idx_dashboard_stage_contents_weekly
    add_index :dashboard_stage_contents, [:kind, :min_age_months, :max_age_months],
      name: :idx_dashboard_stage_contents_monthly
  end
end
