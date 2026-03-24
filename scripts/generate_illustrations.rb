#!/usr/bin/env ruby
# frozen_string_literal: true

# =============================================================================
# Shuby Illustration Generator
# =============================================================================
# Generates illustrations for development area categories and individual
# questionnaire questions using the Gemini 3.1 Flash Image Preview API
# (Nano Banana 2), maintaining visual consistency with existing Shuby brand.
#
# Usage:
#   ruby scripts/generate_illustrations.rb                    # Generate all
#   ruby scripts/generate_illustrations.rb --categories-only  # Categories only
#   ruby scripts/generate_illustrations.rb --questions-only   # Questions only
#   ruby scripts/generate_illustrations.rb --area motricita   # Specific area
#   ruby scripts/generate_illustrations.rb --month 6          # Specific month
#   ruby scripts/generate_illustrations.rb --dry-run          # Show prompts only
#
# Environment:
#   GEMINI_API_KEY - Google AI API key (required)
#
# =============================================================================

require "net/http"
require "json"
require "base64"
require "uri"
require "fileutils"

# =============================================================================
# Configuration
# =============================================================================

API_KEY = ENV.fetch("GEMINI_API_KEY") {
  abort "ERROR: Set GEMINI_API_KEY environment variable. Get one at https://aistudio.google.com/api-keys"
}

MODEL = "gemini-3.1-flash-image-preview"
ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent"

# Paths
PROJECT_ROOT = File.expand_path("..", __dir__)
ILLUSTRATIONS_DIR = File.join(PROJECT_ROOT, "app", "assets", "images", "shuby", "illustrations")
STAGES_DIR = File.join(ILLUSTRATIONS_DIR, "stages")
CATEGORIES_DIR = File.join(ILLUSTRATIONS_DIR, "categories")
QUESTIONS_DIR = File.join(ILLUSTRATIONS_DIR, "questions")
QUESTIONNAIRE_JSON = File.join(PROJECT_ROOT, "db", "seeds", "data", "questionari_completi_5_aree.json")

# Reference images (existing Shuby brand illustrations)
REFERENCE_IMAGES = Dir.glob(File.join(STAGES_DIR, "*.png")).sort

# Image generation settings
ASPECT_RATIO = "1:1"
IMAGE_SIZE = "1K"

# Rate limiting (Gemini free tier: ~15 RPM for image generation)
REQUEST_DELAY_SECONDS = 5

# Retry settings
MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 15

# =============================================================================
# Style Definition
# =============================================================================

SHUBY_STYLE_PROMPT = <<~STYLE
  STYLE REQUIREMENTS (match the reference images exactly):
  - Flat, geometric, minimal vector-style illustration
  - Main character: a white/very light blue pentagon shape with a cute kawaii face (small rectangular eyes, open smiling mouth)
  - Background: solid soft teal/aqua color (#B8E6E6)
  - Shadow: dark teal oval shadow beneath characters
  - Color palette: limited to soft teal, white, medium blue, and one accent color
  - NO gradients, NO textures, NO realistic elements
  - Simple geometric companion shapes (circles, squares, triangles, clouds) in medium blue
  - Clean lines, no outlines, flat filled shapes only
  - Cute, friendly, warm aesthetic suitable for a parenting app
  - NO text or words in the image
  - Centered composition with ample whitespace
  - Minimalist: only 2-4 elements maximum in the scene
STYLE

# =============================================================================
# Development Area Definitions
# =============================================================================

AREA_DEFINITIONS = {
  "comunicazione_linguaggio" => {
    slug: "comunicazione-linguaggio",
    title: "Comunicazione e Linguaggio",
    color: "#EC4899",
    accent_color: "soft pink",
    icon_concept: "speech bubble or sound waves",
    scene_description: "The pentagon character with a speech bubble or sound waves coming from its mouth, suggesting communication and language. A small companion shape nearby appears to be listening."
  },
  "motricita" => {
    slug: "motricita",
    title: "Motricità",
    color: "#10B981",
    accent_color: "soft green",
    icon_concept: "movement or footsteps",
    scene_description: "The pentagon character in a dynamic pose suggesting movement, perhaps tilted or with small motion lines. A simple path or stepping stones nearby in soft green."
  },
  "cognizione_attenzione" => {
    slug: "cognizione-attenzione",
    title: "Cognizione e Attenzione",
    color: "#F59E0B",
    accent_color: "soft amber/yellow",
    icon_concept: "lightbulb or puzzle piece",
    scene_description: "The pentagon character looking at a simple geometric puzzle piece or a small lightbulb shape floating above, suggesting thinking and attention. Soft amber accent color."
  },
  "relazione_regolazione" => {
    slug: "relazione-regolazione",
    title: "Relazione e Regolazione",
    color: "#3B82F6",
    accent_color: "soft blue",
    icon_concept: "heart or two characters together",
    scene_description: "Two pentagon characters side by side (one slightly smaller), with a small heart shape between them, suggesting social bonds and emotional regulation. Soft blue accent."
  },
  "consolidamento" => {
    slug: "consolidamento",
    title: "Consolidamento",
    color: "#6366F1",
    accent_color: "soft indigo/purple",
    icon_concept: "star or checkmark",
    scene_description: "The pentagon character with a small star or circular badge shape nearby, suggesting achievement and consolidation of skills. Soft indigo/purple accent."
  }
}.freeze

# =============================================================================
# Question Scene Descriptions (mapped from Italian question themes)
# =============================================================================

# Maps question themes to illustration scene concepts.
# Groups similar questions to avoid generating near-identical images.
QUESTION_SCENE_MAP = {
  # Communication & Language themes
  "voce" => "reacting to a voice, with small sound wave shapes nearby",
  "piange" => "crying with small teardrop shapes, expressing needs",
  "calma" => "being soothed, with a gentle wavy line suggesting calm",
  "suoni" => "making sounds, with small musical note shapes floating",
  "balbetta" => "babbling with small letter-like shapes coming out",
  "parole" => "speaking a word, with a speech bubble containing a simple shape",
  "nome" => "turning toward its name, with an arrow pointing to it",
  "indica" => "pointing at something with a small hand/arrow shape",
  "frase" => "with a longer speech bubble containing multiple small shapes",
  "racconta" => "telling a story, with small picture-like shapes in sequence",
  "canta" => "singing, with musical notes floating around",
  "domanda" => "with a question mark shape floating nearby",

  # Motor skills themes
  "muove" => "moving limbs, with motion lines around arms and legs",
  "mani" => "looking at or reaching with small hand shapes",
  "testa" => "lifting or turning its head, shown slightly tilted",
  "afferra" => "grasping a small geometric object",
  "rotola" => "rolling, shown tilted at an angle with motion curves",
  "siede" => "sitting upright, stable on a small surface",
  "gatton" => "crawling, shown low with motion lines suggesting movement",
  "cammina" => "walking, with small footprint shapes below",
  "corre" => "running fast, with speed lines behind it",
  "salta" => "jumping in the air, above a small shadow on the ground",
  "scala" => "climbing up steps, shown on simple geometric stairs",
  "disegna" => "drawing, with a crayon shape and simple scribble nearby",
  "pedala" => "on a simple geometric tricycle shape",
  "cucchiaio" => "holding a simple spoon shape, near a bowl",

  # Cognition & Attention themes
  "fissa" => "staring intently at a glowing shape, very focused",
  "guarda" => "looking at something with wide curious eyes",
  "segue" => "following a moving object with its gaze, dotted line showing path",
  "esplora" => "surrounded by different geometric shapes, exploring",
  "oggetto" => "examining a simple geometric object up close",
  "causa" => "pushing a shape and watching another shape react (cause-effect)",
  "incastr" => "fitting a shape into a matching hole (shape sorter)",
  "impil" => "stacking geometric blocks into a tower",
  "colori" => "surrounded by colorful simple circles/squares",
  "puzzle" => "fitting puzzle pieces together",
  "conta" => "next to numbered shapes (1, 2, 3)",
  "memoria" => "with thought-bubble shapes showing remembered objects",
  "forma" => "identifying different geometric shapes laid out in front",

  # Social-Emotional themes
  "contatto" => "being hugged or close to another character, warm and cozy",
  "sorriso" => "smiling broadly with a happy expression",
  "separa" => "looking toward a departing character with concern",
  "gioco" => "playing with another character, sharing toy shapes",
  "coopera" => "working together with another character on building blocks",
  "emozion" => "with different emotion faces shown as small companion shapes",
  "turno" => "waiting in line behind another character, patient",
  "regol" => "calming down, with slow breathing waves shown",
  "condivid" => "sharing a shape/toy with another character",
  "amicizi" => "walking side by side with another character, both happy",
  "dorme" => "sleeping peacefully with small Z shapes floating",

  # Consolidation themes
  "consolid" => "with a small star badge, showing mastery of a skill",
  "ripete" => "doing an action again with a circular arrow suggesting repetition",
  "conferma" => "with a checkmark shape floating nearby, skill confirmed"
}.freeze

# =============================================================================
# API Functions
# =============================================================================

def load_reference_images
  REFERENCE_IMAGES.map do |path|
    {
      "inline_data" => {
        "mime_type" => "image/png",
        "data" => Base64.strict_encode64(File.binread(path))
      }
    }
  end
end

def generate_image(prompt, reference_parts, aspect_ratio: ASPECT_RATIO, image_size: IMAGE_SIZE)
  parts = [{ "text" => prompt }] + reference_parts

  body = {
    "contents" => [{ "parts" => parts }],
    "generationConfig" => {
      "responseModalities" => %w[TEXT IMAGE],
      "imageConfig" => {
        "aspectRatio" => aspect_ratio,
        "imageSize" => image_size
      }
    },
    "safetySettings" => [
      { "category" => "HARM_CATEGORY_HARASSMENT", "threshold" => "BLOCK_ONLY_HIGH" },
      { "category" => "HARM_CATEGORY_HATE_SPEECH", "threshold" => "BLOCK_ONLY_HIGH" },
      { "category" => "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold" => "BLOCK_ONLY_HIGH" },
      { "category" => "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold" => "BLOCK_ONLY_HIGH" }
    ]
  }

  uri = URI("#{ENDPOINT}?key=#{API_KEY}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.read_timeout = 120
  http.open_timeout = 30

  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "application/json"
  request.body = body.to_json

  response = http.request(request)
  JSON.parse(response.body)
end

def extract_and_save_image(response_json, output_path)
  candidates = response_json["candidates"] || []
  candidates.each do |candidate|
    parts = candidate.dig("content", "parts") || []
    parts.each do |part|
      # Gemini API returns camelCase keys (inlineData), not snake_case
      image_data = part["inlineData"] || part["inline_data"]
      next unless image_data
      image_bytes = Base64.decode64(image_data["data"])
      FileUtils.mkdir_p(File.dirname(output_path))
      File.binwrite(output_path, image_bytes)
      return output_path
    end
  end

  # Check for error/block
  if response_json["error"]
    error = response_json["error"]
    puts "  API error: #{error["code"]} - #{error["message"]}"
  elsif response_json.dig("candidates", 0, "finishReason") == "SAFETY"
    puts "  Blocked by safety filter"
  else
    puts "  No image in response. Keys found:"
    parts = response_json.dig("candidates", 0, "content", "parts") || []
    parts.each_with_index { |p, i| puts "    part[#{i}]: #{p.keys.inspect}" }
  end

  nil
end

def generate_with_retry(prompt, reference_parts, output_path, dry_run: false)
  if dry_run
    puts "  PROMPT: #{prompt[0..200]}..."
    puts "  OUTPUT: #{output_path}"
    return true
  end

  # Skip if already generated
  if File.exist?(output_path) && File.size(output_path) > 1000
    puts "  SKIP (already exists): #{output_path}"
    return true
  end

  retries = 0
  loop do
    response = generate_image(prompt, reference_parts)
    saved = extract_and_save_image(response, output_path)

    if saved
      size_kb = (File.size(saved) / 1024.0).round(1)
      puts "  SAVED (#{size_kb}KB): #{saved}"
      return true
    end

    retries += 1
    if retries >= MAX_RETRIES
      puts "  FAILED after #{MAX_RETRIES} retries"
      return false
    end

    puts "  Retrying in #{RETRY_DELAY_SECONDS}s... (attempt #{retries + 1}/#{MAX_RETRIES})"
    sleep(RETRY_DELAY_SECONDS)
  end
end

# =============================================================================
# Prompt Builders
# =============================================================================

def build_category_prompt(area_key, area_def)
  <<~PROMPT
    Generate a single illustration for a parenting app called "Shuby".

    Use the 4 provided reference images as your EXACT STYLE GUIDE. Match their visual style precisely.

    #{SHUBY_STYLE_PROMPT}

    SUBJECT: "#{area_def[:title]}" development area icon illustration.
    SCENE: #{area_def[:scene_description]}
    ACCENT COLOR: Use #{area_def[:accent_color]} (#{area_def[:color]}) as the single accent color for companion elements.

    Create a clean, minimal illustration with the pentagon mascot character and 1-2 simple companion shapes that represent #{area_def[:title].downcase}. The image must work as a category icon at small sizes (128x128px).
  PROMPT
end

def find_scene_for_question(question_text)
  question_lower = question_text.downcase
  QUESTION_SCENE_MAP.each do |keyword, scene|
    return scene if question_lower.include?(keyword)
  end
  # Fallback: generic scene based on the question text
  "illustrating the concept: '#{question_text}', represented with simple geometric shapes"
end

def build_question_prompt(question, area_def, month)
  scene = find_scene_for_question(question[:text])
  age_context = case month
  when 0..3 then "newborn baby (0-3 months)"
  when 4..6 then "young infant (4-6 months)"
  when 7..9 then "older infant (7-9 months)"
  when 10..12 then "baby approaching first year (10-12 months)"
  when 13..18 then "young toddler (13-18 months)"
  when 19..24 then "toddler (19-24 months)"
  when 25..30 then "older toddler (25-30 months)"
  else "preschool child (31-36 months)"
  end

  <<~PROMPT
    Generate a single illustration for a parenting app called "Shuby".

    Use the provided reference images as your EXACT STYLE GUIDE. Match their visual style precisely.

    #{SHUBY_STYLE_PROMPT}

    CONTEXT: Developmental milestone question for a #{age_context}.
    AREA: #{area_def[:title]} (accent: #{area_def[:accent_color]})
    QUESTION: "#{question[:text]}"

    SCENE: The pentagon mascot character #{scene}.
    ACCENT COLOR: Use #{area_def[:accent_color]} (#{area_def[:color]}) for companion elements.

    The illustration should visually represent the milestone described in the question. Keep it minimal with the mascot and 1-2 simple companion elements. Must work at small sizes.
  PROMPT
end

# =============================================================================
# Load Questionnaire Data
# =============================================================================

def load_questionnaire_data
  data = JSON.parse(File.read(QUESTIONNAIRE_JSON))
  areas = {}

  data["questionari_mensili"].each do |mese|
    month = mese["mese"]
    mese["aree"].each do |area_key, area_data|
      areas[area_key] ||= { title: area_data["titolo"], questions: [] }
      area_data["domande"].each do |q|
        areas[area_key][:questions] << {
          id: q["id"],
          month: month,
          text: q["domanda"]
        }
      end
    end
  end

  areas
end

# =============================================================================
# Generation Phases
# =============================================================================

def generate_categories(reference_parts, dry_run: false)
  puts "\n#{"=" * 60}"
  puts "PHASE 1: Generating Category Illustrations"
  puts "#{"=" * 60}\n"

  results = { success: 0, failed: 0, skipped: 0 }

  AREA_DEFINITIONS.each do |area_key, area_def|
    output_path = File.join(CATEGORIES_DIR, "#{area_def[:slug]}.png")
    puts "\n[#{area_def[:title]}]"

    prompt = build_category_prompt(area_key, area_def)
    if generate_with_retry(prompt, reference_parts, output_path, dry_run: dry_run)
      results[:success] += 1
    else
      results[:failed] += 1
    end

    sleep(REQUEST_DELAY_SECONDS) unless dry_run
  end

  puts "\nCategories: #{results[:success]} ok, #{results[:failed]} failed"
  results
end

def generate_questions(reference_parts, areas_data, filter_area: nil, filter_month: nil, dry_run: false)
  puts "\n#{"=" * 60}"
  puts "PHASE 2: Generating Question Illustrations"
  puts "#{"=" * 60}\n"

  results = { success: 0, failed: 0, skipped: 0 }
  total_questions = 0

  # Build augmented reference: original references + generated category images
  augmented_refs = reference_parts.dup
  AREA_DEFINITIONS.each do |_area_key, area_def|
    cat_path = File.join(CATEGORIES_DIR, "#{area_def[:slug]}.png")
    if File.exist?(cat_path) && File.size(cat_path) > 1000
      augmented_refs << {
        "inline_data" => {
          "mime_type" => "image/png",
          "data" => Base64.strict_encode64(File.binread(cat_path))
        }
      }
    end
  end

  # Cap references to avoid token limits (keep original 4 + up to 5 category imgs)
  augmented_refs = augmented_refs.first(9)

  areas_data.each do |area_key, area_info|
    area_def = AREA_DEFINITIONS[area_key]
    next unless area_def
    next if filter_area && area_def[:slug] != filter_area

    puts "\n--- #{area_def[:title]} (#{area_info[:questions].size} questions) ---"

    area_info[:questions].each do |question|
      next if filter_month && question[:month] != filter_month

      total_questions += 1
      area_subdir = File.join(QUESTIONS_DIR, area_def[:slug])
      output_path = File.join(area_subdir, "#{question[:id]}.png")

      puts "\n  [m#{question[:month]}] #{question[:id]}: #{question[:text][0..60]}"

      prompt = build_question_prompt(question, area_def, question[:month])
      if generate_with_retry(prompt, augmented_refs, output_path, dry_run: dry_run)
        results[:success] += 1
      else
        results[:failed] += 1
      end

      sleep(REQUEST_DELAY_SECONDS) unless dry_run
    end
  end

  puts "\nQuestions: #{results[:success]}/#{total_questions} ok, #{results[:failed]} failed"
  results
end

# =============================================================================
# Progress Tracking
# =============================================================================

def save_progress(progress_file, completed_ids)
  File.write(progress_file, completed_ids.to_json)
end

def load_progress(progress_file)
  return Set.new unless File.exist?(progress_file)
  Set.new(JSON.parse(File.read(progress_file)))
end

# =============================================================================
# Main
# =============================================================================

def main
  args = ARGV

  dry_run = args.delete("--dry-run")
  categories_only = args.delete("--categories-only")
  questions_only = args.delete("--questions-only")

  filter_area = nil
  if (idx = args.index("--area"))
    filter_area = args[idx + 1]
    args.delete_at(idx + 1)
    args.delete_at(idx)
  end

  filter_month = nil
  if (idx = args.index("--month"))
    filter_month = args[idx + 1].to_i
    args.delete_at(idx + 1)
    args.delete_at(idx)
  end

  puts "=" * 60
  puts "Shuby Illustration Generator"
  puts "=" * 60
  puts "Model: #{MODEL}"
  puts "Reference images: #{REFERENCE_IMAGES.size}"
  puts "Output directories:"
  puts "  Categories: #{CATEGORIES_DIR}"
  puts "  Questions:  #{QUESTIONS_DIR}"
  puts "Dry run: #{dry_run ? "YES" : "no"}"
  puts "Filter area: #{filter_area || "all"}"
  puts "Filter month: #{filter_month || "all"}"
  puts

  # Validate reference images exist
  if REFERENCE_IMAGES.empty?
    abort "ERROR: No reference images found in #{STAGES_DIR}"
  end

  puts "Loading reference images..."
  reference_parts = load_reference_images
  puts "Loaded #{reference_parts.size} reference images"

  puts "Loading questionnaire data..."
  areas_data = load_questionnaire_data
  total_questions = areas_data.values.sum { |a| a[:questions].size }
  puts "Loaded #{areas_data.size} areas, #{total_questions} questions"

  # Ensure output directories
  FileUtils.mkdir_p(CATEGORIES_DIR)
  FileUtils.mkdir_p(QUESTIONS_DIR)
  AREA_DEFINITIONS.each do |_key, area_def|
    FileUtils.mkdir_p(File.join(QUESTIONS_DIR, area_def[:slug]))
  end

  # Phase 1: Categories
  unless questions_only
    generate_categories(reference_parts, dry_run: dry_run)
  end

  # Phase 2: Questions
  unless categories_only
    generate_questions(
      reference_parts,
      areas_data,
      filter_area: filter_area,
      filter_month: filter_month,
      dry_run: dry_run
    )
  end

  puts "\n#{"=" * 60}"
  puts "Generation complete!"
  puts "=" * 60

  # Summary of generated files
  cat_count = Dir.glob(File.join(CATEGORIES_DIR, "*.png")).size
  q_count = Dir.glob(File.join(QUESTIONS_DIR, "**", "*.png")).size
  puts "Category illustrations: #{cat_count}/#{AREA_DEFINITIONS.size}"
  puts "Question illustrations: #{q_count}/#{total_questions}"
end

main
