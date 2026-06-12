# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  draw :accounts
  draw :api
  draw :archive
  draw :beta_feedback
  draw :billing
  draw :children
  draw :development_stages
  draw :measurements
  draw :pediatrician_reports
  draw :family_profiles
  draw :hotwire_native
  draw :onboarding
  draw :shuby
  draw :users
  draw :dev if Rails.env.local?

  authenticated :user, lambda { |u| u.admin? } do
    draw :madmin
  end

  resources :announcements, only: [:index, :show]

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :consenso_informato, path: "consenso-informato"
    get :reset_app
    get :app_preview
    get :native_debug
    post :toggle_debug
  end

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    root to: "dashboard#show", as: :user_root
    get "today", to: "dashboard#show"  # Dedicated path for Ruby Native iOS tab
    get "settings", to: "settings#show"
    namespace :settings do
      resource :privacy, only: [:show, :update], controller: "privacy" do
        post :export, on: :member
      end
      resource :pdf, only: [:show, :update], controller: "pdf"
    end
    resources :child_selections, only: [:update]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker

  # Visitatori non autenticati: schermata di accesso (con link "Registrati").
  # Il marketing pubblico vive ora sul sito esterno (https://www.shuby.app).
  devise_scope :user do
    root to: "users/sessions#new"
  end
end
