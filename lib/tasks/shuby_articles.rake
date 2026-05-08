# frozen_string_literal: true

namespace :shuby do
  namespace :articles do
    desc "Re-parse docs/Articoli/*.docx and write db/seeds/archive_articles.json (local-only; .docx files are gitignored)"
    task dump: :environment do
      Shuby::Articles::Dumper.new(
        root: Rails.root.join("docs/Articoli"),
        output_path: Rails.root.join("db/seeds/archive_articles.json"),
        io: $stdout
      ).run
    end

    desc "Seed ArchiveContent articles from db/seeds/archive_articles.json"
    task seed: :environment do
      Shuby::Articles::Seeder.new(
        json_path: Rails.root.join("db/seeds/archive_articles.json"),
        io: $stdout
      ).run
    end
  end
end
