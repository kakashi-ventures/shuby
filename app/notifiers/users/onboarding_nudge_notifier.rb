class Users::OnboardingNudgeNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  deliver_by ApplicationNotifier::IOS_ADAPTER do |config|
    ApplicationNotifier.apns_defaults(config)
    config.format = ->(apn) { event.format_apns(apn, recipient) }
  end

  def first_child
    account.children.active.first
  end

  def format_apns(apn, recipient)
    apn.alert = {
      title: I18n.t("notifications.users.onboarding_nudge.push.title"),
      body: I18n.t("notifications.users.onboarding_nudge.push.body", name: first_child&.display_name || "tuo figlio")
    }
    apn.sound = "default"
    apn.badge = recipient.notifications.unread.count
  end

  def message
    I18n.t("notifications.users.onboarding_nudge.message", name: first_child&.display_name || "tuo figlio")
  end

  def url
    first_child ? child_measurements_path(child_id: first_child.id) : root_path
  end
end
