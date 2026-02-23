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
puts "Loading from: db/seeds/data/questionari_completi_5_aree.json"
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

json_file = Rails.root.join("db", "seeds", "data", "questionari_completi_5_aree.json")

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
# 4. Load Warning Signs and Stimulation Activities
# =============================================================================

puts "Loading warning signs and stimulation activities..."

json_file = Rails.root.join("db", "seeds", "data", "campanelli_attivita.json")

if File.exist?(json_file)
  json_data = JSON.parse(File.read(json_file))

  # Clear existing data for fresh import
  WarningSign.delete_all
  StimulationActivity.delete_all

  warning_signs_created = 0
  activities_created = 0

  # Load Warning Signs
  json_data["warning_signs"].each do |month_data|
    month = month_data["month"]
    month_data["items"].each_with_index do |description, index|
      WarningSign.create!(
        month: month,
        description: description,
        position: index
      )
      warning_signs_created += 1
    end
  end

  # Load Stimulation Activities
  json_data["stimulation_activities"].each do |month_data|
    month = month_data["month"]
    month_data["items"].each_with_index do |description, index|
      StimulationActivity.create!(
        month: month,
        description: description,
        position: index
      )
      activities_created += 1
    end
  end

  puts "  - Warning Signs: #{warning_signs_created}"
  puts "  - Stimulation Activities: #{activities_created}"
else
  puts "WARNING: campanelli_attivita.json not found. Skipping warning signs and stimulation activities loading."
end

puts ""
puts "=" * 60
puts "Development stages seeded successfully!"
puts "Summary:"
puts "  - Areas: #{DevelopmentArea.count}"
puts "  - Questionnaires: #{AgeBandQuestionnaire.count} (new: #{questionnaires_created})"
puts "  - Questions: #{Question.count} (new: #{questions_created})"
puts "  - Warning Signs: #{WarningSign.count}"
puts "  - Stimulation Activities: #{StimulationActivity.count}"
puts "=" * 60

# =============================================================================
# 5. Growth Phases - Developmental milestones by age range
# =============================================================================

puts ""
puts "=" * 60
puts "Growth Phases Seed Data"
puts "=" * 60

GROWTH_PHASES = [
  {
    min_age_months: 0, max_age_months: 2,
    title: "Il mondo dei sensi",
    description: "In questa fase il tuo bambino sta scoprendo il mondo attraverso i sensi. Parla con lui, accarezzalo e permettigli di esplorare oggetti sicuri.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 2, max_age_months: 4,
    title: "Sta arrivando il sorriso sociale",
    description: "Garantisci al tuo bambino almeno 30 minuti totali di tummy time al giorno. Usa la tua voce e i canti e ricorda niente schermi.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 4, max_age_months: 6,
    title: "Esplorazione attiva",
    description: "Il tuo bambino inizia a esplorare attivamente il mondo. Offrigli giocattoli sicuri da afferrare e lascialo sperimentare diverse texture.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 6, max_age_months: 9,
    title: "Primi movimenti",
    description: "È il momento della scoperta del movimento! Incoraggia il gattonamento e crea spazi sicuri per l'esplorazione.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 9, max_age_months: 12,
    title: "Comunicazione emergente",
    description: "Il tuo bambino sta sviluppando le prime forme di comunicazione. Rispondi ai suoi gesti e balbettii per incoraggiare il linguaggio.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 12, max_age_months: 18,
    title: "Primi passi e prime parole",
    description: "Un periodo entusiasmante di grandi conquiste! Sostieni i primi passi e celebra ogni nuova parola.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 18, max_age_months: 24,
    title: "Indipendenza crescente",
    description: "Il tuo bambino vuole fare sempre più cose da solo. Lascialo provare e guidalo con pazienza nelle nuove sfide.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 24, max_age_months: 30,
    title: "Esplosione del linguaggio",
    description: "Le parole aumentano ogni giorno! Leggi insieme, canta e conversa per stimolare lo sviluppo del linguaggio.",
    illustration_key: "growth-phase-mascot.svg"
  },
  {
    min_age_months: 30, max_age_months: 37,
    title: "Socializzazione e gioco",
    description: "Il tuo bambino è pronto per interagire con altri bambini. Favorisci le occasioni di gioco condiviso e socializzazione.",
    illustration_key: "growth-phase-mascot.svg"
  }
].freeze

puts "Seeding growth phases..."
GROWTH_PHASES.each_with_index do |data, index|
  GrowthPhase.find_or_create_by!(
    min_age_months: data[:min_age_months],
    max_age_months: data[:max_age_months]
  ) do |phase|
    phase.title = data[:title]
    phase.description = data[:description]
    phase.illustration_key = data[:illustration_key]
    phase.position = index
  end
end

puts "Created #{GrowthPhase.count} growth phases"
puts "=" * 60

# =============================================================================
# 6. Archive Content - Educational articles, books, and activities
# =============================================================================

puts ""
puts "=" * 60
puts "Archive Content Seed Data"
puts "=" * 60

ARCHIVE_CONTENTS = [
  # Articles
  {
    title: "Benessere emotivo della famiglia",
    description: "Tutto quello che c'è da sapere sulla salute emotiva della famiglia nel post-partum",
    content_type: :article,
    category: "Benessere famigliare",
    min_age_months: 0,
    max_age_months: 6,
    published: true
  },
  {
    title: "5 cose che dovresti sapere sul contatto pelle a pelle",
    description: "Il contatto pelle a pelle è molto più di un gesto d'amore: scopri perché è fondamentale",
    content_type: :article,
    category: "Neurosviluppo",
    min_age_months: 0,
    max_age_months: 6,
    published: true
  },
  {
    title: "Il tempo speciale: un dono di attenzione",
    description: "Un dono reciproco di attenzione, ascolto e amore",
    content_type: :article,
    category: "Attaccamento",
    min_age_months: 0,
    max_age_months: 36,
    published: true
  },
  # Books
  {
    title: "Quelli là",
    description: "Un libro illustrato per i più piccoli",
    content_type: :book,
    category: "Lettura",
    author: "Teresa Porcella",
    publisher: "Bacchilega Editore",
    min_age_months: 0,
    max_age_months: 12,
    published: true
  },
  {
    title: "Il viaggio di piedino",
    description: "Una storia tenera sul primo viaggio",
    content_type: :book,
    category: "Lettura",
    author: "Elisa Mazzoli, Marianna Balducci",
    publisher: "Bacchilega Editore",
    min_age_months: 0,
    max_age_months: 12,
    published: true
  },
  # Games/Activities
  {
    title: "Guarda lo specchio... chi c'è qui?",
    content_type: :game,
    category: "Giochi",
    min_age_months: 0,
    max_age_months: 2,
    duration_minutes: 3,
    published: true
  },
  {
    title: "La danza degli sguardi",
    content_type: :game,
    category: "Giochi",
    min_age_months: 0,
    max_age_months: 2,
    duration_minutes: 3,
    published: true
  },
  {
    title: "Tummy time musicale",
    content_type: :game,
    category: "Attività",
    min_age_months: 0,
    max_age_months: 6,
    duration_minutes: 5,
    published: true
  },
  {
    title: "Massaggio mani e piedi",
    content_type: :game,
    category: "Attività",
    min_age_months: 0,
    max_age_months: 12,
    duration_minutes: 5,
    published: true
  },
  {
    title: "Musica classica",
    content_type: :game,
    category: "Attività",
    min_age_months: 0,
    max_age_months: 36,
    duration_minutes: 5,
    published: true
  },
  {
    title: 'Momento "viso a viso"',
    content_type: :game,
    category: "Attività",
    min_age_months: 0,
    max_age_months: 6,
    duration_minutes: 5,
    published: true
  }
].freeze

puts "Seeding archive content..."
ARCHIVE_CONTENTS.each do |data|
  slug = data[:title].parameterize
  content = ArchiveContent.find_or_initialize_by(slug: slug)
  content.assign_attributes(data)
  content.save!
end

puts "Created #{ArchiveContent.count} archive content items"
puts "  - Articles: #{ArchiveContent.articles.count}"
puts "  - Books: #{ArchiveContent.books.count}"
puts "  - Games/Activities: #{ArchiveContent.games.count}"
puts "=" * 60
