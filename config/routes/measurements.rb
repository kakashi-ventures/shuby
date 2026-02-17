# frozen_string_literal: true

# Measurement routes (Italian: misurazioni)
resources :children, only: [] do
  resources :measurements, path: "misurazioni"
end
