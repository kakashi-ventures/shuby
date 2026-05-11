class Children::MilestoneReminderNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  deliver_by ApplicationNotifier::IOS_ADAPTER do |config|
    ApplicationNotifier.apns_defaults(config)
    config.format = ->(apn) { event.format_apns(apn, recipient) }
  end

  def format_apns(apn, recipient)
    apn.alert = {
      title: I18n.t("notifications.children.milestone_reminder.push.title"),
      body: I18n.t("notifications.children.milestone_reminder.push.body", name: record.display_name)
    }
    apn.sound = "default"
    apn.badge = recipient.notifications.unread.count
  end

  def message
    I18n.t("notifications.children.milestone_reminder.message", name: record.display_name)
  end

  def url
    child_development_stages_path(child_id: record.id)
  end
end
