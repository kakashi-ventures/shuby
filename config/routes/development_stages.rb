# frozen_string_literal: true

# Development Stages routes (Italian: tappe-di-sviluppo)
resources :children, only: [] do
  # Main development stages pages
  resources :development_stages, path: "tappe-di-sviluppo", only: [:index, :show] do
    member do
      get :start # Start new session for a questionnaire
    end
  end

  # Questionnaire session flow
  resources :questionnaire_sessions, path: "questionari", only: [:show, :edit, :update] do
    member do
      get :continue # Resume questionnaire (fallback)
      get :stories # Stories-style questionnaire (default)
      post :answer # Submit answer to a question
      patch :complete # Mark as complete
    end
  end
end
