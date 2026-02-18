# frozen_string_literal: true

# Pediatrician report and questions routes
resources :children, only: [] do
  resource :pediatrician_report, only: [:show], path: "report-pediatra"
  resources :pediatrician_questions, path: "domande-pediatra", only: [:create, :destroy]
end
