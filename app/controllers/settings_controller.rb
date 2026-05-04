class SettingsController < ApplicationController
  before_action :authenticate_user!

  ALLOWED_TABS = %w[family plan configuration].freeze
  DEFAULT_TAB = "family"

  def show
    @tab = ALLOWED_TABS.include?(params[:tab]) ? params[:tab] : DEFAULT_TAB

    case @tab
    when "family"
      @children = current_account.children.active.order(:birth_date)
      @adult_members = [current_user]
    when "plan"
      plans = Plan.visible.sorted
      @monthly_plans, @yearly_plans = plans.partition(&:monthly?)
    end
  end
end
