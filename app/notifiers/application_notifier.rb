class ApplicationNotifier < Noticed::Event
  IOS_ADAPTER = Rails.env.test? ? :test : :ios
  QUIET_HOURS_RANGE = (22..23).to_a + (0..7).to_a

  def to_websocket(notification)
    {
      account_id: account_id,
      html: ApplicationController.render(partial: "notifications/notification", locals: {notification: notification})
    }
  end

  def ios_device_tokens(user)
    user.notification_tokens.ios.pluck(:token)
  end

  def android_device_tokens(user)
    user.notification_tokens.android.pluck(:token)
  end

  def cleanup_device_token(token:, platform:)
    NotificationToken.where(token: token, platform: platform).destroy_all
  end

  def push_allowed?(recipient)
    Rails.application.config.x.push_notifications_enabled &&
      recipient.push_notifications_enabled &&
      self.class.deliverable_to?(recipient)
  end

  def self.deliverable_to?(recipient)
    zone = ActiveSupport::TimeZone[recipient.time_zone.presence || "Europe/Rome"]
    !QUIET_HOURS_RANGE.include?(zone.now.hour)
  end

  def self.apns_defaults(config)
    apns = Rails.application.config.x.apns
    config.bundle_identifier = apns.bundle_identifier
    config.team_id = apns.team_id
    config.key_id = apns.key_id
    config.apns_key = apns.auth_key
    config.development = apns.development
    config.device_tokens = -> { event.ios_device_tokens(recipient) }
    config.if = -> { event.push_allowed?(recipient) }
    config.invalid_token = ->(token) { event.cleanup_device_token(token: token, platform: "iOS") }
    config.error_handler = ->(exception) { Rails.logger.tagged("APNS") { Rails.logger.error(exception.full_message) } }
  end
end
