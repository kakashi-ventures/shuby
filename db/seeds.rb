# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
# Uncomment the following to create an Admin user for Production in Jumpstart Pro
#
#   user = User.create(
#     name: "Admin User",
#     email: "email@example.org",
#     password: "password",
#     password_confirmation: "password",
#     terms_of_service: true
#   )
#   Jumpstart.grant_system_admin!(user)

# =============================================================================
# Development Stages Seed Data
# =============================================================================

puts "Creating development areas..."
AREAS = [
  {name: "Generale", slug: "generale", color: "#6366F1", position: 1},
  {name: "Comunicazione e Linguaggio", slug: "comunicazione-linguaggio", color: "#EC4899", position: 2},
  {name: "Motricità", slug: "motricita", color: "#10B981", position: 3},
  {name: "Cognizione e Attenzione", slug: "cognizione-attenzione", color: "#F59E0B", position: 4},
  {name: "Relazione e Regolazione", slug: "relazione-regolazione", color: "#3B82F6", position: 5}
]

AREAS.each do |data|
  DevelopmentArea.find_or_create_by!(slug: data[:slug]) do |area|
    area.name = data[:name]
    area.color = data[:color]
    area.position = data[:position]
  end
end

puts "Creating age band questionnaires..."
AGE_BANDS = [
  {min: 0, max: 3},
  {min: 3, max: 6},
  {min: 6, max: 9},
  {min: 9, max: 12},
  {min: 12, max: 18},
  {min: 18, max: 24},
  {min: 24, max: 30},
  {min: 30, max: 36}
]

DevelopmentArea.find_each do |area|
  AGE_BANDS.each_with_index do |band, index|
    AgeBandQuestionnaire.find_or_create_by!(
      development_area: area,
      min_age_months: band[:min]
    ) do |q|
      q.max_age_months = band[:max]
      q.position = index
    end
  end
end

puts "Creating sample questions..."

# Sample questions for each area for the 0-3 month band
generale = DevelopmentArea.find_by!(slug: "generale")
comunicazione = DevelopmentArea.find_by!(slug: "comunicazione-linguaggio")
motricita = DevelopmentArea.find_by!(slug: "motricita")
cognizione = DevelopmentArea.find_by!(slug: "cognizione-attenzione")
relazione = DevelopmentArea.find_by!(slug: "relazione-regolazione")

# Generale 0-3m
q = generale.age_band_questionnaires.find_by!(min_age_months: 0)
[
  "Il bambino reagisce a stimoli visivi e sonori?",
  "Il bambino mostra interesse per l'ambiente circostante?",
  "Il bambino ha periodi di veglia tranquilla durante il giorno?",
  "Il bambino si calma quando viene confortato?",
  "Il bambino ha un ritmo sonno-veglia che sta iniziando a regolarizzarsi?",
  "Il bambino mostra espressioni facciali variegate?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Comunicazione 0-3m
q = comunicazione.age_band_questionnaires.find_by!(min_age_months: 0)
[
  "Il bambino emette suoni vocalici (oo, aa)?",
  "Il bambino si gira verso la voce dei genitori?",
  "Il bambino piange in modo differenziato per esprimere bisogni diversi?",
  "Il bambino guarda il volto di chi gli parla?",
  "Il bambino mostra interesse quando gli si parla?",
  "Il bambino inizia a sorridere in risposta a stimoli sociali?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Motricità 0-3m
q = motricita.age_band_questionnaires.find_by!(min_age_months: 0)
[
  "Il bambino tiene la testa sollevata quando è a pancia in giù?",
  "Il bambino muove braccia e gambe in modo simmetrico?",
  "Il bambino afferra oggetti messi nella sua mano (riflesso di prensione)?",
  "Il bambino segue oggetti in movimento con gli occhi?",
  "Il bambino inizia a controllare i movimenti della testa quando è in braccio?",
  "Il bambino porta le mani alla bocca?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Cognizione 0-3m
q = cognizione.age_band_questionnaires.find_by!(min_age_months: 0)
[
  "Il bambino segue oggetti con lo sguardo?",
  "Il bambino mostra interesse per volti e oggetti?",
  "Il bambino reagisce a suoni improvvisi?",
  "Il bambino fissa il volto dei genitori?",
  "Il bambino inizia a anticipare eventi familiari (es. poppata)?",
  "Il bambino mostra preferenza per alcuni stimoli rispetto ad altri?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Relazione 0-3m
q = relazione.age_band_questionnaires.find_by!(min_age_months: 0)
[
  "Il bambino riconosce il volto dei genitori?",
  "Il bambino si calma quando viene preso in braccio?",
  "Il bambino mostra il sorriso sociale?",
  "Il bambino cerca il contatto visivo?",
  "Il bambino si tranquillizza con la voce familiare?",
  "Il bambino mostra preferenza per le figure di accudimento?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Add a few questions for 3-6 month band as well
# Motricità 3-6m
q = motricita.age_band_questionnaires.find_by!(min_age_months: 3)
[
  "Il bambino solleva la testa e il petto quando è a pancia in giù?",
  "Il bambino si gira da pancia in giù a pancia in su?",
  "Il bambino afferra oggetti volontariamente?",
  "Il bambino porta oggetti alla bocca?",
  "Il bambino inizia a stare seduto con supporto?",
  "Il bambino calcia energicamente quando è sdraiato?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

# Comunicazione 3-6m
q = comunicazione.age_band_questionnaires.find_by!(min_age_months: 3)
[
  "Il bambino balbetta con varietà di suoni?",
  "Il bambino ride e vocalizza in risposta alle interazioni?",
  "Il bambino risponde quando chiamato per nome?",
  "Il bambino imita alcuni suoni?",
  "Il bambino usa diverse tonalità di voce?",
  "Il bambino comunica con gesti e vocalizzi?"
].each_with_index do |prompt, index|
  Question.find_or_create_by!(age_band_questionnaire: q, prompt: prompt) do |question|
    question.position = index
  end
end

puts "Development stages seeded successfully!"
