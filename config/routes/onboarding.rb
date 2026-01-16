# frozen_string_literal: true

scope :onboarding, as: :onboarding do
  get :family_profile, to: "onboarding#family_profile"
  patch :family_profile, to: "onboarding#update_family_profile"

  get :children, to: "onboarding#children"
  patch :children, to: "onboarding#update_children"

  get :health_history, to: "onboarding#health_history"
  patch :health_history, to: "onboarding#update_health_history"

  get :complete, to: "onboarding#complete"
  post :finish, to: "onboarding#finish"
end
