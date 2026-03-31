# frozen_string_literal: true

class ReplaceMontlyQuestionnairesWithClinicalBands < ActiveRecord::Migration[8.1]
  def up
    # destroy_all triggers Rails callbacks → cascades to questions and questionnaire_sessions
    AgeBandQuestionnaire.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
