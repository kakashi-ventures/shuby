# frozen_string_literal: true

# Synchronises the "inherited si" question_responses across all of one child's
# questionnaire sessions for a given (content_key, development_area) pair.
#
# Scope is restricted to a single development_area: questions sharing text
# across DIFFERENT areas (e.g., a motricità prompt re-asked in the consolidamento
# area) are intentionally NOT propagated — re-asking in a different
# developmental context is a content-team design choice.
#
# The invariant maintained, per (content_key, development_area, child):
#
#   IF any direct (non-inherited) "si" exists for this content_key in this area
#   THEN every other session in this area covering an equivalent question carries an inherited "si"
#   ELSE no inherited rows for this (content_key, area) exist anywhere under this child
#
# Direct (non-inherited) responses are never touched — parent's own answer always wins.
class EquivalentAnswerPropagator
  def self.recompute(content_key:, child:, development_area_id:)
    new(content_key, child, development_area_id).call
  end

  def initialize(content_key, child, development_area_id)
    @content_key = content_key
    @child = child
    @development_area_id = development_area_id
  end

  def call
    return if @content_key.blank?
    return if @development_area_id.blank?

    if authoritative_yes?
      ensure_inherited_rows
    else
      remove_inherited_rows
    end
  end

  private

  def authoritative_yes?
    base_scope.where(answer: :si, inherited: false).exists?
  end

  def ensure_inherited_rows
    target_sessions.each do |session|
      equivalent_q = session.age_band_questionnaire.questions.find_by(content_key: @content_key)
      next unless equivalent_q

      existing = session.question_responses.find_by(question: equivalent_q)
      next if existing && !existing.inherited?

      if existing
        existing.update!(answer: :si) if existing.answer != "si"
      else
        QuestionResponse.create!(
          questionnaire_session: session,
          question: equivalent_q,
          answer: :si,
          inherited: true
        )
      end
    end
  end

  def remove_inherited_rows
    base_scope.where(inherited: true).destroy_all
  end

  def base_scope
    QuestionResponse.joins(:question, questionnaire_session: :age_band_questionnaire)
      .where(questions: {content_key: @content_key})
      .where(questionnaire_sessions: {child_id: @child.id})
      .where(age_band_questionnaires: {development_area_id: @development_area_id})
  end

  def target_sessions
    @child.questionnaire_sessions
      .joins(:age_band_questionnaire)
      .where(age_band_questionnaires: {development_area_id: @development_area_id})
      .includes(age_band_questionnaire: :questions)
  end
end
