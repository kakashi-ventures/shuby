# frozen_string_literal: true

# Middleware-level abuse protection. Layered on top of controller-level Rails 8
# `rate_limit` calls already in place on Devise auth actions — defense in depth.
# All limits tunable via ENV. Disabled in test by default; tests opt-in per-case.

class Rack::Attack
  GLOBAL_LIMIT = Integer(ENV.fetch("RACK_ATTACK_GLOBAL_LIMIT", 300))
  GLOBAL_PERIOD = Integer(ENV.fetch("RACK_ATTACK_GLOBAL_PERIOD", 5 * 60))
  API_LIMIT = Integer(ENV.fetch("RACK_ATTACK_API_LIMIT", 60))
  API_PERIOD = Integer(ENV.fetch("RACK_ATTACK_API_PERIOD", 60))
  API_TOKEN_LIMIT = Integer(ENV.fetch("RACK_ATTACK_API_TOKEN_LIMIT", 120))
  AUTH_LIMIT = Integer(ENV.fetch("RACK_ATTACK_AUTH_LIMIT", 5))
  AUTH_PERIOD = Integer(ENV.fetch("RACK_ATTACK_AUTH_PERIOD", 20))
  REPORT_LIMIT = Integer(ENV.fetch("RACK_ATTACK_REPORT_LIMIT", 10))
  REPORT_PERIOD = Integer(ENV.fetch("RACK_ATTACK_REPORT_PERIOD", 60 * 60))

  API_PATH = %r{\A/api(/|_tokens(/|\z))}
  AUTH_PATHS = %r{\A/(users/(sign_in|sign_up|password)|api/v1/(auth|password))/?\z}
  WEBHOOK_PATHS = %r{\A/(webhooks|pay)(/|\z)}
  REPORT_PATH = %r{\A/children/\d+/pediatrician-report}

  self.enabled = !Rails.env.test?
  cache.store = Rails.cache

  safelist("allow-loopback-in-dev") do |req|
    Rails.env.development? && %w[127.0.0.1 ::1].include?(req.ip)
  end

  safelist("skip-webhooks") { |req| WEBHOOK_PATHS.match?(req.path) }

  throttle("req/ip", limit: GLOBAL_LIMIT, period: GLOBAL_PERIOD) { |req| req.ip }

  throttle("api/ip", limit: API_LIMIT, period: API_PERIOD) do |req|
    req.ip if API_PATH.match?(req.path)
  end

  throttle("api/token", limit: API_TOKEN_LIMIT, period: API_PERIOD) do |req|
    next unless API_PATH.match?(req.path)
    token = req.env["HTTP_AUTHORIZATION"].to_s.split(" ").last
    Digest::SHA256.hexdigest(token) if token.present?
  end

  throttle("auth/ip", limit: AUTH_LIMIT, period: AUTH_PERIOD) do |req|
    req.ip if req.post? && AUTH_PATHS.match?(req.path)
  end

  throttle("report/ip", limit: REPORT_LIMIT, period: REPORT_PERIOD) do |req|
    req.ip if REPORT_PATH.match?(req.path)
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    period = match_data[:period] || 60
    limit = match_data[:limit] || 0
    epoch = match_data[:epoch_time] || Time.now.to_i

    headers = {
      "Retry-After" => period.to_s,
      "RateLimit-Limit" => limit.to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => (epoch + period).to_s
    }

    body =
      if json_response?(request)
        headers["Content-Type"] = "application/json; charset=utf-8"
        {error: "rate_limit_exceeded", retry_after: period}.to_json
      else
        headers["Content-Type"] = "text/html; charset=utf-8"
        I18n.with_locale(I18n.default_locale) do
          ApplicationController.renderer.render(
            template: "errors/too_many_requests",
            layout: false,
            assigns: {retry_after: period}
          )
        end
      end

    [429, headers, [body]]
  end

  def self.json_response?(request)
    API_PATH.match?(request.path) ||
      request.get_header("HTTP_ACCEPT").to_s.include?("application/json")
  end
end
