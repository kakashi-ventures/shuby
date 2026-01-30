# frozen_string_literal: true

module User::Onboarding
  extend ActiveSupport::Concern

  ONBOARDING_STEPS = %w[setup complete].freeze

  included do
    enum :onboarding_step, {
      setup: 0,
      complete: 1
    }, prefix: :onboarding
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current, onboarding_step: :complete)
  end

  def current_onboarding_step
    onboarding_step || "setup"
  end
end
