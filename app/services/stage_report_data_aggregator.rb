# frozen_string_literal: true

# Aggregates a single age band's questionnaire results for StageReportPdf.
#
# Reuses ChildMilestonesLoader — the single source of truth for a band's
# development areas + sessions — and reshapes its output into the flat
# structure the PDF service renders. One entry per development area available
# at the band, each carrying its questions and the child's answers.
class StageReportDataAggregator
  def self.call(child, band)
    new(child, band).call
  end

  def initialize(child, band)
    @child = child
    @band = band
  end

  def call
    {
      header: header_data,
      areas: areas_data
    }
  end

  private

  attr_reader :child, :band

  def header_data
    {
      child_name: child.display_name,
      band_label: "#{band[:label_type]} #{band[:label_number]}",
      generated_at: Time.current
    }
  end

  def areas_data
    band_data = ChildMilestonesLoader.new(child).data_for_band(band)
    band_data[:development_areas].map { |entry| area_row(entry) }
  end

  def area_row(entry)
    questionnaire = entry[:questionnaire]
    session = entry[:session]

    {
      area_name: entry[:area].name,
      age_band_label: questionnaire&.age_band_label,
      status: status_for(questionnaire, session),
      completed_at: session&.completed_at,
      yes_count: session&.yes_count || 0,
      no_count: session&.no_count || 0,
      unknown_count: session&.unknown_count || 0,
      questions: questions_for(questionnaire, session)
    }
  end

  def status_for(questionnaire, session)
    return :not_available if questionnaire.nil?
    return :completed if session&.completed?
    return :in_progress if session&.in_progress?
    :not_started
  end

  def questions_for(questionnaire, session)
    return [] if questionnaire.nil?

    responses = responses_by_question_id(session)
    questionnaire.questions.map do |question|
      {prompt: question.prompt, answer: responses[question.id]&.answer}
    end
  end

  # Preload the session's responses keyed by question id so per-question lookup
  # is a hash hit, not a query each.
  def responses_by_question_id(session)
    return {} if session.nil?
    session.question_responses.index_by(&:question_id)
  end
end
