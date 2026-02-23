class RenameAttivitaStimolazioneToStimulationActivities < ActiveRecord::Migration[8.1]
  def change
    rename_table :attivita_stimolazione, :stimulation_activities
  end
end
