# frozen_string_literal: true

# Measurement routes
resources :children, only: [] do
  resources :measurements, path: "measurements"
end
