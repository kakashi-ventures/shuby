# frozen_string_literal: true

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

require "json"

puts "=" * 60
puts "Development Stages Seed Data"
puts "Loading from: docs/Shuby_Questionari_Completi_5_Aree.json"
puts "=" * 60

# =============================================================================
# 0. Clean up deprecated data
# =============================================================================

# Remove deprecated "Generale" area (replaced by "Consolidamento")
if (generale_area = DevelopmentArea.find_by(slug: "generale"))
  puts "Removing deprecated 'Generale' area and its associated data..."
  generale_area.destroy!
  puts "Deprecated 'Generale' area removed."
end

# Clear existing questions to ensure clean data from official file (covers 0-36 months)
# (This removes old placeholder questions that differ from official file)
# Must also clear responses and sessions first due to foreign key constraints
if QuestionResponse.exists?
  puts "Clearing #{QuestionResponse.count} existing question responses..."
  QuestionResponse.delete_all
end

if QuestionnaireSession.exists?
  puts "Clearing #{QuestionnaireSession.count} existing questionnaire sessions..."
  QuestionnaireSession.delete_all
end

if Question.exists?
  puts "Clearing #{Question.count} existing questions for fresh import..."
  Question.delete_all
end

# =============================================================================
# 1. Create Development Areas (5 areas - matches official file, 0-36 months)
# =============================================================================

puts "Creating development areas..."
AREAS = [
  {name: "Comunicazione e Linguaggio", slug: "comunicazione-linguaggio", color: "#EC4899", position: 1},
  {name: "Motricità", slug: "motricita", color: "#10B981", position: 2},
  {name: "Cognizione e Attenzione", slug: "cognizione-attenzione", color: "#F59E0B", position: 3},
  {name: "Relazione e Regolazione", slug: "relazione-regolazione", color: "#3B82F6", position: 4},
  {name: "Consolidamento", slug: "consolidamento", color: "#6366F1", position: 5}
].freeze

AREAS.each do |data|
  area = DevelopmentArea.find_or_initialize_by(slug: data[:slug])
  area.name = data[:name]
  area.color = data[:color]
  area.position = data[:position]
  area.save!
end

puts "Created #{DevelopmentArea.count} development areas"

# =============================================================================
# 2. Load JSON file
# =============================================================================

json_file = Rails.root.join("docs", "Shuby_Questionari_Completi_5_Aree.json")

unless File.exist?(json_file)
  puts "WARNING: JSON file not found at #{json_file}"
  puts "Skipping questionnaire and question seeding. Please add the file and re-run seeds."
  exit
end

data = JSON.parse(File.read(json_file))

# Map JSON area keys to database slugs
AREA_KEY_MAP = {
  "comunicazione_linguaggio" => "comunicazione-linguaggio",
  "motricita" => "motricita",
  "cognizione_attenzione" => "cognizione-attenzione",
  "relazione_regolazione" => "relazione-regolazione",
  "consolidamento" => "consolidamento"
}.freeze

# =============================================================================
# 3. Create Monthly Questionnaires and Questions from JSON
# =============================================================================

puts "Creating monthly questionnaires and loading questions..."

questionnaires_created = 0
questions_created = 0

data["questionari_mensili"].each do |month_data|
  month = month_data["mese"]

  month_data["aree"].each do |area_key, area_data|
    slug = AREA_KEY_MAP[area_key]
    next unless slug # Skip unknown areas

    area = DevelopmentArea.find_by(slug: slug)
    next unless area

    # Create or find questionnaire for this month/area
    questionnaire = AgeBandQuestionnaire.find_or_create_by!(
      development_area: area,
      min_age_months: month
    ) do |q|
      q.max_age_months = month + 1
      q.position = month
      q.title = "#{area_data["titolo"]} - #{month_data["eta_descrizione"]}"
    end

    questionnaires_created += 1 if questionnaire.previously_new_record?

    # Create questions for this questionnaire
    questions_array = area_data["domande"] || []
    questions_array.each_with_index do |q_data, index|
      prompt = q_data["domanda"]
      next if prompt.blank?

      question = Question.find_or_create_by!(
        age_band_questionnaire: questionnaire,
        prompt: prompt
      ) do |question|
        question.position = index
        question.active = true
      end

      questions_created += 1 if question.previously_new_record?
    end
  end

  print "." if month % 5 == 0
end

puts ""
puts "Development stages questions loaded."

# =============================================================================
# 4. Load Campanelli d'Allarme and Attività di Stimolazione
# =============================================================================

puts "Loading campanelli d'allarme and attività di stimolazione..."

campanelli_json = Rails.root.join("docs", "campanelli_attivita.json")

if File.exist?(campanelli_json)
  campanelli_data = JSON.parse(File.read(campanelli_json))

  # Clear existing data for fresh import
  CampanelloAllarme.delete_all
  AttivitaStimolazione.delete_all

  campanelli_created = 0
  attivita_created = 0

  # Load Campanelli d'Allarme
  campanelli_data["campanelli_allarme"].each do |month_data|
    month = month_data["month"]
    month_data["items"].each_with_index do |description, index|
      CampanelloAllarme.create!(
        month: month,
        description: description,
        position: index
      )
      campanelli_created += 1
    end
  end

  # Load Attività di Stimolazione
  campanelli_data["attivita_stimolazione"].each do |month_data|
    month = month_data["month"]
    month_data["items"].each_with_index do |description, index|
      AttivitaStimolazione.create!(
        month: month,
        description: description,
        position: index
      )
      attivita_created += 1
    end
  end

  puts "  - Campanelli d'Allarme: #{campanelli_created}"
  puts "  - Attività di Stimolazione: #{attivita_created}"
else
  puts "WARNING: campanelli_attivita.json not found. Skipping campanelli and attività loading."
end

puts ""
puts "=" * 60
puts "Development stages seeded successfully!"
puts "Summary:"
puts "  - Areas: #{DevelopmentArea.count}"
puts "  - Questionnaires: #{AgeBandQuestionnaire.count} (new: #{questionnaires_created})"
puts "  - Questions: #{Question.count} (new: #{questions_created})"
puts "  - Campanelli d'Allarme: #{CampanelloAllarme.count}"
puts "  - Attività di Stimolazione: #{AttivitaStimolazione.count}"
puts "=" * 60
