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
    @milestone_session = result[:session]
  end

  def load_measurement_boxes
    @measurement_boxes = MeasurementDashboardService.call(current_child)
  end

  def load_dashboard_content
    content = DashboardContentService.call(current_child)
    @activities = content[:activities]
    @tips = content[:tips]
    @featured_articles = content[:articles]
    @favorite_ids = Set.new(current_user.archive_favorites.pluck(:archive_content_id))
  end
end
