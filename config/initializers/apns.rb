Rails.application.config.x.apns = ActiveSupport::OrderedOptions.new.tap do |c|
  c.bundle_identifier = "app.shuby.rubynative"
  c.team_id = Rails.application.credentials.dig(:apns, :team_id)
  c.key_id = Rails.application.credentials.dig(:apns, :key_id)
  c.auth_key = Rails.application.credentials.dig(:apns, :auth_key)
  c.development = !Rails.env.production?
end

Rails.application.config.x.push_notifications_enabled = true
