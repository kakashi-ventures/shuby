# frozen_string_literal: true

module QuestionnaireSessionsHelper
  # Generates a personalized completion summary based on the child's answers
  def completion_summary(session, child, area)
    return "" unless session.questions_count.positive?

    yes_percentage = (session.yes_count.to_f / session.questions_count * 100).round

    key = if yes_percentage >= 80
      "summary_excellent_html"
    elsif yes_percentage >= 50
      "summary_good_html"
    else
      "summary_developing_html"
    end

    t("questionnaire_sessions.stories.#{key}",
      name: child.display_name,
      area: area.name.downcase)
  end
end
