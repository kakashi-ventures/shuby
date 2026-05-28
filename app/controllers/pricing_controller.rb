# Overrides lib/jumpstart/app/controllers/pricing_controller.rb. The plan
# list now lives canonically at /settings?tab=plan; /pricing redirects so
# legacy bookmarks, paywall banners, and engine error fallbacks
# (CheckoutsController rescues Pay::Error to pricing_path) all converge
# on the same destination.
class PricingController < ApplicationController
  def show
    redirect_to settings_path(tab: "plan"), status: :moved_permanently
  end
end
