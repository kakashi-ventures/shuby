# frozen_string_literal: true

module QuestionnaireSessionsHelper
  # Generates a personalized completion summary based on the child's answers
  def completion_summary(session, child, area)
    return "" unless session.questions_count.positive?

    yes_percentage = (session.yes_count.to_f / session.questions_count * 100).round

    if yes_percentage >= 80
      t("questionnaire_sessions.stories.summary_excellent",
        name: child.display_name,
        area: area.name.downcase)
    elsif yes_percentage >= 50
      t("questionnaire_sessions.stories.summary_good",
        name: child.display_name,
        area: area.name.downcase)
    else
      t("questionnaire_sessions.stories.summary_developing",
        name: child.display_name,
        area: area.name.downcase)
    end
  end
end
