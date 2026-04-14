# frozen_string_literal: true

class BetaFeedback < ApplicationRecord
  belongs_to :user
  belongs_to :account

  has_one_attached :screenshot

  enum :feedback_type, {bug: 0, suggestion: 1, praise: 2, other: 3}
  enum :severity, {low: 0, medium: 1, high: 2, critical: 3}, prefix: :severity
  enum :status, {new_feedback: 0, in_review: 1, resolved: 2, wont_fix: 3}, prefix: :status

  validates :section, presence: true
  validates :page_url, presence: true
  validates :description, presence: true, length: {minimum: 10, maximum: 2000}
  validates :feedback_type, presence: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :by_section, ->(section) { where(section: section) }
  scope :by_status, ->(status) { where(status: status) }
  scope :unresolved, -> { where.not(status: [:resolved, :wont_fix]) }

  SECTION_MAP = {
    "dashboard" => "Oggi",
    "children" => "Profilo Bambino",
    "measurements" => "Misurazioni",
    "development_stages" => "Tappe di Sviluppo",
    "questionnaires" => "Questionari",
    "archive" => "Archivio",
    "shuby" => "Assistente Shuby",
    "settings" => "Impostazioni",
    "family_profiles" => "Profilo Famiglia",
    "pediatrician_reports" => "Report Pediatra",
    "onboarding" => "Onboarding",
    "other" => "Altro"
  }.freeze

  FEEDBACK_TYPE_LABELS = {
    "bug" => "Problema / Bug",
    "suggestion" => "Suggerimento",
    "praise" => "Apprezzamento",
    "other" => "Altro"
  }.freeze

  SEVERITY_LABELS = {
    "low" => "Bassa",
    "medium" => "Media",
    "high" => "Alta",
    "critical" => "Critica"
  }.freeze

  STATUS_LABELS = {
    "new_feedback" => "Nuovo",
    "in_review" => "In revisione",
    "resolved" => "Risolto",
    "wont_fix" => "Non corretto"
  }.freeze

  def section_display_name
    SECTION_MAP[section] || section.humanize
  end

  def self.section_from_path(path)
    return "dashboard" if path.blank? || path == "/" || path == "/today"

    segments = path.delete_prefix("/").split("/")
    first_segment = segments.first

    case first_segment
    when "children"
      nested = segments[2]&.tr("-", "_")
      (nested && SECTION_MAP.key?(nested)) ? nested : "children"
    when "archive" then "archive"
    when "shuby" then "shuby"
    when "settings" then "settings"
    when "today" then "dashboard"
    when "family-profiles" then "family_profiles"
    when "pediatrician-reports" then "pediatrician_reports"
    when "onboarding" then "onboarding"
    else "other"
    end
  end
end
