class DashboardController < ApplicationController
  def show
    if current_child.present?
      load_todays_milestone
      load_measurement_boxes
      load_dashboard_content
    end
  end

  private

  def load_todays_milestone
    result = DailyMilestoneService.call(current_child)
    @todays_milestone = result[:milestone]
    @milestone_state = result[:state]
  end

  def load_measurement_boxes
    @measurement_boxes = MeasurementDashboardService.call(current_child)
  end

  def load_dashboard_content
    age = current_child.questionnaire_age_in_months
    @activities = ArchiveContent.published.games.for_age(age).ordered.limit(3)
    @tips = ArchiveContent.published.tips.for_age(age).ordered.limit(2)
    @featured_articles = ArchiveContent.published.articles.for_age(age).ordered.limit(3)
  end
end
