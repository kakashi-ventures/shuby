# frozen_string_literal: true

namespace :shuby do
  namespace :articles do
    desc "Seed ArchiveContent articles from docs/Articoli/<Categoria>/*.docx"
    task seed: :environment do
      Shuby::Articles::Seeder.new(
        root: Rails.root.join("docs/Articoli"),
        io: $stdout
      ).run
    end
  end
end
