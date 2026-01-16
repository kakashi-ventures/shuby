# frozen_string_literal: true

module User::Onboarding
  extend ActiveSupport::Concern

  ONBOARDING_STEPS = %w[family_profile children health_history complete].freeze

  included do
    enum :onboarding_step, {
      family_profile: 0,
      children: 1,
      health_history: 2,
      complete: 3
    }, prefix: :onboarding
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current, onboarding_step: :complete)
  end

  def current_onboarding_step
    onboarding_step || "family_profile"
  end

  def advance_onboarding_step!
    current_index = ONBOARDING_STEPS.index(onboarding_step.to_s)
    return if current_index.nil?

    next_step = ONBOARDING_STEPS[current_index + 1]
    update!(onboarding_step: next_step) if next_step
  end

  def onboarding_step_index
    ONBOARDING_STEPS.index(current_onboarding_step.to_s) || 0
  end

  def can_access_step?(step)
    target_index = ONBOARDING_STEPS.index(step.to_s)
    return false unless target_index

    target_index <= onboarding_step_index
  end
end
