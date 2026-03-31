# frozen_string_literal: true

class AddLabelToAgeBandQuestionnaires < ActiveRecord::Migration[8.0]
  # Labels keyed by min_age_months — mirrors the old CLINICAL_BANDS constant
  BAND_LABELS = {
    0 => "1° Mese",
    2 => "3° Mese",
    5 => "6° Mese",
    8 => "9° Mese",
    11 => "12° Mese",
    18 => "18-24° Mesi",
    36 => "36° Mese"
  }.freeze

  def up
    add_column :age_band_questionnaires, :label, :string

    BAND_LABELS.each do |min_age, label|
      AgeBandQuestionnaire.where(min_age_months: min_age).update_all(label: label)
    end

    change_column_null :age_band_questionnaires, :label, false, "Unknown"
  end

  def down
    remove_column :age_band_questionnaires, :label
  end
end
