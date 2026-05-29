# frozen_string_literal: true

namespace :shuby do
  namespace :activities do
    desc "Seed ArchiveContent activities from db/seeds/archive_activities.json"
    task seed: :environment do
      Shuby::Activities::Seeder.new(
        json_path: Rails.root.join("db/seeds/archive_activities.json"),
        io: $stdout
      ).run
    end
  end
end
