class Account::OwnershipNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  deliver_by ApplicationNotifier::IOS_ADAPTER do |config|
    ApplicationNotifier.apns_defaults(config)
    config.format = ->(apn) { event.format_apns(apn, recipient) }
  end

  def previous_owner
    record || params[:previous_owner] || User.new(name: "Someone")
  end

  def format_apns(apn, recipient)
    apn.alert = {
      title: I18n.t("notifications.account.ownership_notifier.push.title"),
      body: I18n.t("notifications.account.ownership_notifier.push.body", previous_owner: previous_owner.name)
    }
    apn.sound = "default"
    apn.badge = recipient.notifications.unread.count
  end

  def message
    t "notifications.account_transferred", previous_owner: previous_owner.name, account: account.name
  end

  def url
    account_path(account)
  end
end
