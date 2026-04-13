# frozen_string_literal: true

# Routes for Archive educational content
resources :archive, path: "archive", only: [:index, :show] do
  resource :favorite, controller: "archive_favorites", only: [:create, :destroy], path: "favorite"
end
