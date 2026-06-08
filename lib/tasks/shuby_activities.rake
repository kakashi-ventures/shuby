# frozen_string_literal: true

namespace :shuby do
  namespace :activities do
    desc "Re-parse docs/Activities/*.docx and write db/seeds/archive_activities.json (local-only; .docx files are gitignored)"
    task dump: :environment do
      Shuby::Activities::Dumper.new(
        root: Rails.root.join("docs/Activities"),
        output_path: Rails.root.join("db/seeds/archive_activities.json"),
        io: $stdout
      ).run
    end

    desc "Seed ArchiveContent activities from db/seeds/archive_activities.json"
    task seed: :environment do
      Shuby::Activities::Seeder.new(
        json_path: Rails.root.join("db/seeds/archive_activities.json"),
        io: $stdout
      ).run
    end
  end
end
