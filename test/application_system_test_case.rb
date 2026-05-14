require "test_helper"
require "axe/matchers/be_axe_clean"

Dir["#{File.dirname(__FILE__)}/support/system/**/*.rb"].sort.each { |f| require f }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Backport
  def self.served_by(host:, port:)
    Capybara.server_host = host
    Capybara.server_port = port
  end

  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "rails-app", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: ENV.fetch("DRIVER", :headless_chrome).to_sym, screen_size: [1400, 1400]
  end

  include Warden::Test::Helpers
  include TrixSystemTestHelper

  def switch_account(account)
    visit test_switch_account_url(account)
  end

  # WCAG 2.1 Level AA accessibility assertion. Runs axe-core inside the
  # current browser session. `tags` controls which rule sets axe enforces
  # (defaults to WCAG 2.0 A + AA which together cover WCAG 2.1 AA for
  # automated checks). `skip_rules` accepts axe rule IDs to disable for
  # this assertion only — use sparingly and document the reason inline at
  # the callsite.
  def assert_accessible(tags: %i[wcag2a wcag2aa], skip_rules: [])
    matcher = Axe::Matchers.be_axe_clean.according_to(*tags)
    matcher = matcher.skipping(*skip_rules) if skip_rules.any?
    assert matcher.matches?(page), matcher.failure_message
  end
end

Capybara.default_max_wait_time = 10

# Add a route for easily switching accounts in system tests
Rails.application.routes.append do
  get "/accounts/:id/switch", to: "accounts#switch", as: :test_switch_account
end
Rails.application.reload_routes!
