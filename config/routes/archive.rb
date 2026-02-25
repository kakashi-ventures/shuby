# frozen_string_literal: true

# Routes for Archivio (Archive) educational content
resources :archive, path: "archivio", only: [:index, :show] do
  resource :favorite, controller: "archive_favorites", only: [:create, :destroy], path: "preferito"
end
