# frozen_string_literal: true

# Pediatrician report and questions routes
resources :children, only: [] do
  resource :pediatrician_report, only: [:show], path: "pediatrician-report"
  resources :pediatrician_questions, path: "pediatrician-questions", only: [:create, :destroy]
end
