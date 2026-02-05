class DashboardController < ApplicationController
  def show
    load_todays_milestone if current_child.present?
  end

  private

  def load_todays_milestone
    result = DailyMilestoneService.call(current_child)
    @todays_milestone = result[:milestone]
    @milestone_state = result[:state]
  end
end
