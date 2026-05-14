ENV["RAILS_ENV"] ||= "test"
ENV["RACK_ATTACK_GLOBAL_LIMIT"] ||= "5"
ENV["RACK_ATTACK_GLOBAL_PERIOD"] ||= "60"
ENV["RACK_ATTACK_API_LIMIT"] ||= "3"
ENV["RACK_ATTACK_API_PERIOD"] ||= "60"
ENV["RACK_ATTACK_API_TOKEN_LIMIT"] ||= "4"
ENV["RACK_ATTACK_AUTH_LIMIT"] ||= "2"
ENV["RACK_ATTACK_AUTH_PERIOD"] ||= "60"
ENV["RACK_ATTACK_REPORT_LIMIT"] ||= "2"
ENV["RACK_ATTACK_REPORT_PERIOD"] ||= "60"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require "webmock/minitest"

# Uncomment to view full stack trace in tests
# Rails.backtrace_cleaner.remove_silencers!

if defined?(Sidekiq)
  require "sidekiq/testing"
  Sidekiq.logger.level = Logger::WARN
end

if defined?(SolidQueue)
  SolidQueue.logger.level = Logger::WARN
end

# Generate a random password so Chrome doesn't warn about passwords in data breaches
UNIQUE_PASSWORD = Devise.friendly_token

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Declare custom fixture classes
    set_fixture_class stimulation_activities: StimulationActivity

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def json_response
      JSON.decode(response.body)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    def switch_account(account)
      patch "/accounts/#{account.id}/switch"
    end
  end
end

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: [
    "chromedriver.storage.googleapis.com",
    "rails-app",
    "selenium"
  ]
})
