# frozen_string_literal: true

class AddRecommendationsToArchiveContents < ActiveRecord::Migration[8.0]
  def change
    add_column :archive_contents, :recommendations, :text, array: true, default: [], null: false
  end
end
