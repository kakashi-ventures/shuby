# frozen_string_literal: true

module OnboardingRequired
  extend ActiveSupport::Concern

  included do
    before_action :require_onboarding_completed
  end

  private

  def require_onboarding_completed
    return unless user_signed_in?
    return if current_user.onboarding_completed?
    return if controller_path == "onboarding"
    return if devise_controller?

    redirect_to onboarding_path,
      alert: I18n.t("onboarding.required")
  end
end
