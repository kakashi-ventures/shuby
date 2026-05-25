# frozen_string_literal: true

class AddBirthHeightCmToChildHealthProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :child_health_profiles, :birth_height_cm, :decimal, precision: 4, scale: 1
  end
end
