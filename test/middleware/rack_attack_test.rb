require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    @original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
  end

  teardown do
    Rack::Attack.enabled = false
    Rack::Attack.cache.store = @original_store
  end

  test "global per-IP throttle returns 429 after limit" do
    (Rack::Attack::GLOBAL_LIMIT + 1).times { get "/up", env: ip("1.2.3.4") }
    assert_equal 429, response.status
  end

  test "throttle response carries RFC-style RateLimit headers" do
    (Rack::Attack::GLOBAL_LIMIT + 1).times { get "/up", env: ip("1.2.3.5") }
    assert_equal 429, response.status
    assert_predicate response.headers["Retry-After"], :present?
    assert_predicate response.headers["RateLimit-Limit"], :present?
    assert_equal "0", response.headers["RateLimit-Remaining"]
    assert_predicate response.headers["RateLimit-Reset"], :present?
  end

  test "API path returns JSON-shaped 429 body" do
    (Rack::Attack::API_LIMIT + 1).times { get "/api/v1/me", env: ip("1.2.3.6") }
    assert_equal 429, response.status
    assert_includes response.media_type, "application/json"
    body = JSON.parse(response.body)
    assert_equal "rate_limit_exceeded", body["error"]
    assert_kind_of Integer, body["retry_after"]
  end

  test "browser path returns HTML 429 with Italian copy" do
    (Rack::Attack::GLOBAL_LIMIT + 1).times { get "/users/sign_in", env: ip("1.2.3.7") }
    assert_equal 429, response.status
    assert_includes response.media_type, "text/html"
    assert_match(/Troppe richieste/, response.body)
  end

  test "auth-strict throttle catches password-spray on /users/sign_in" do
    (Rack::Attack::AUTH_LIMIT + 1).times do
      post "/users/sign_in",
        params: {user: {email: "intruder@example.com", password: "wrong"}},
        env: ip("1.2.3.8")
    end
    assert_equal 429, response.status
  end

  test "different IPs do not share the same bucket" do
    Rack::Attack::API_LIMIT.times { get "/api/v1/me", env: ip("1.2.3.9") }
    refute_equal 429, response.status
    get "/api/v1/me", env: ip("1.2.3.10")
    refute_equal 429, response.status
  end

  test "webhook paths are safelisted past the global limit" do
    over = Rack::Attack::GLOBAL_LIMIT + 5
    over.times { get "/webhooks/stripe", env: ip("1.2.3.11") }
    refute_equal 429, response.status
  end

  test "loopback IP is safelisted in development" do
    Rails.stub(:env, ActiveSupport::StringInquirer.new("development")) do
      over = Rack::Attack::GLOBAL_LIMIT + 5
      over.times { get "/up", env: ip("127.0.0.1") }
      refute_equal 429, response.status
    end
  end

  test "Rack::Attack is disabled by default in test env" do
    Rack::Attack.enabled = false
    over = Rack::Attack::GLOBAL_LIMIT * 3
    over.times { get "/up", env: ip("1.2.3.13") }
    refute_equal 429, response.status
  end

  test "JSON branch keys off Accept header on non-API path" do
    (Rack::Attack::GLOBAL_LIMIT + 1).times do
      get "/up", env: ip("1.2.3.14"), headers: {"Accept" => "application/json"}
    end
    assert_equal 429, response.status
    assert_includes response.media_type, "application/json"
  end

  private

  def ip(addr)
    {"REMOTE_ADDR" => addr}
  end
end
