# frozen_string_literal: true

# Development Stages routes
resources :children, only: [] do
  # Main development stages pages
  resources :development_stages, path: "development-stages", only: [:index, :show] do
    collection do
      get :timeline_content # Turbo Frame endpoint for age band content
    end
    member do
      get :start # Start new session for a questionnaire
    end
  end

  # Per-stage PDF export — :id is the age-band key (e.g. "sett_5", "mese_12")
  resources :stage_reports, path: "stage-reports", only: [:show]

  # Questionnaire session flow
  resources :questionnaire_sessions, path: "questionnaires", only: [:show, :edit, :update] do
    member do
      get :continue # Resume questionnaire (fallback)
      get :overlay_frame # Turbo-frame content loaded into the questionnaire overlay
      post :answer # Submit answer to a question
      patch :complete # Mark as complete
    end
  end
end
