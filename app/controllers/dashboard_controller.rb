class DashboardController < ApplicationController
  def show
    if current_child.present?
      load_todays_milestone
      load_measurement_boxes
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
end
