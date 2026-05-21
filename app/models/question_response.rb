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
  after_destroy :update_session_status
  after_save :propagate_inheritance, if: -> { saved_change_to_answer? && !inherited? }
  after_destroy :recompute_inheritance, unless: :inherited?

  private

  def update_session_status
    session = questionnaire_session

    if session.not_started?
      session.update!(status: :in_progress, started_at: Time.current)
    end

    if session.yes_count == session.questions_count
      session.complete! unless session.completed?
    elsif session.completed?
      session.update!(status: :in_progress, completed_at: nil)
    end
  end

  def propagate_inheritance
    return if question.content_key.blank?
    EquivalentAnswerPropagator.recompute(
      content_key: question.content_key,
      child: questionnaire_session.child,
      development_area_id: question.age_band_questionnaire.development_area_id
    )
  end

  def recompute_inheritance
    return if question.content_key.blank?
    EquivalentAnswerPropagator.recompute(
      content_key: question.content_key,
      child: questionnaire_session.child,
      development_area_id: question.age_band_questionnaire.development_area_id
    )
  end

  # Prevent answer changes after 14-day edit window expires
  def answer_not_locked
    return unless answer_changed?
    return if questionnaire_session.editable?
    errors.add(:answer, :locked)
  end
end
