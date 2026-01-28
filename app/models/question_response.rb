# frozen_string_literal: true

class QuestionResponse < ApplicationRecord
  belongs_to :questionnaire_session
  belongs_to :question

  enum :answer, {incerto: 0, si: 1, no: 2}

  validates :answer, presence: true
  validates :question_id, uniqueness: {scope: :questionnaire_session_id}
  validate :answer_not_locked, on: :update

  # Normalize text fields to strip whitespace
  normalizes :notes, with: ->(value) { value.is_a?(String) ? value.strip.squeeze(" ") : value }

  after_save :update_session_status

  private

  def update_session_status
    session = questionnaire_session
    if session.not_started?
      session.update!(status: :in_progress, started_at: Time.current)
    end

    # Auto-complete if all questions answered
    if session.answered_count == session.questions_count
      session.complete!
    end
  end

  # Prevent answer changes after 14-day edit window expires
  def answer_not_locked
    return unless answer_changed?
    return if questionnaire_session.editable?
    errors.add(:answer, :locked)
  end
end
