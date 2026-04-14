# frozen_string_literal: true

namespace :beta do
  desc "Enable beta_tester flag for all existing users"
  task enable_all: :environment do
    count = User.where(beta_tester: false).update_all(beta_tester: true)
    puts "#{count} utenti abilitati come beta tester"
  end

  desc "Disable beta_tester flag for all users"
  task disable_all: :environment do
    count = User.where(beta_tester: true).update_all(beta_tester: false)
    puts "#{count} utenti rimossi dai beta tester"
  end
end
