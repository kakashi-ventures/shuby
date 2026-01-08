# frozen_string_literal: true

class QuestionResponse < ApplicationRecord
  belongs_to :questionnaire_session
  belongs_to :question

  enum :answer, {non_lo_so: 0, si: 1, no: 2}

  validates :answer, presence: true
  validates :question_id, uniqueness: {scope: :questionnaire_session_id}

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
end
