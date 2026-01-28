# frozen_string_literal: true

class QuestionnaireSession < ApplicationRecord
  belongs_to :child
  belongs_to :age_band_questionnaire
  has_many :question_responses, dependent: :destroy

  enum :status, {not_started: 0, in_progress: 1, completed: 2}

  validates :status, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :for_area, ->(area) { joins(:age_band_questionnaire).where(age_band_questionnaires: {development_area_id: area.id}) }

  before_create :snapshot_metadata

  # Progress tracking
  def questions_count
    age_band_questionnaire.questions.active.count
  end
  alias_method :total_questions, :questions_count

  def answered_count
    question_responses.count
  end

  def progress_fraction
    "#{answered_count}/#{questions_count}"
  end

  def progress_percentage
    return 0 if questions_count.zero?
    ((answered_count.to_f / questions_count) * 100).round
  end

  # Response analysis
  def yes_count
    question_responses.where(answer: :si).count
  end

  def no_count
    question_responses.where(answer: :no).count
  end

  def unknown_count
    question_responses.where(answer: :incerto).count
  end
  alias_method :si_count, :yes_count
  alias_method :incerto_count, :unknown_count

  def development_area
    age_band_questionnaire.development_area
  end

  def mark_in_progress!
    update!(status: :in_progress, started_at: Time.current)
  end

  def mark_completed!
    update!(status: :completed, completed_at: Time.current)
  end

  def needs_attention?
    # Gentle alert: multiple "No" answers (threshold: 2+ or >30%)
    return false unless completed?
    no_count >= 2 || (answered_count > 0 && (no_count.to_f / answered_count) > 0.3)
  end

  def response_for(question)
    question_responses.find_by(question: question)
  end

  def next_unanswered_question
    answered_ids = question_responses.pluck(:question_id)
    age_band_questionnaire.questions.where.not(id: answered_ids).first
  end

  def complete!
    update!(status: :completed, completed_at: Time.current)
  end

  # Editing capability - allow updates within 14 days of completion
  # @return [Boolean] true if session can be edited
  def editable?
    completed? && completed_at.present? && completed_at > 14.days.ago
  end

  # Calculate when editing will be locked
  # @return [Time, nil] the deadline for editing
  def editing_deadline
    completed_at + 14.days if completed_at.present?
  end

  # Calculate days remaining until locked
  # @return [Integer] number of days until editing is locked
  def days_until_locked
    return 0 unless editable?
    ((editing_deadline - Time.current) / 1.day).ceil
  end

  # Check if session was answered with current questionnaire version
  # @return [Boolean] true if answered with latest version
  def answered_with_current_version?
    return true if questionnaire_version.nil? # Legacy sessions
    age_band_questionnaire.version == questionnaire_version
  end

  private

  def snapshot_metadata
    self.child_age_months ||= child.age_in_months
    self.questionnaire_version ||= age_band_questionnaire.version
  end
end
