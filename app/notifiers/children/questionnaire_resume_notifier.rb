class Children::QuestionnaireResumeNotifier < ApplicationNotifier
  deliver_by :action_cable do |config|
    config.channel = "Noticed::NotificationChannel"
    config.stream = -> { recipient }
    config.message = :to_websocket
  end

  deliver_by ApplicationNotifier::IOS_ADAPTER do |config|
    ApplicationNotifier.apns_defaults(config)
    config.format = ->(apn) { event.format_apns(apn, recipient) }
  end

  def child
    record.child
  end

  def format_apns(apn, recipient)
    apn.alert = {
      title: I18n.t("notifications.children.questionnaire_resume.push.title"),
      body: I18n.t("notifications.children.questionnaire_resume.push.body", name: child.display_name)
    }
    apn.sound = "default"
    apn.badge = recipient.notifications.unread.count
  end

  def message
    I18n.t("notifications.children.questionnaire_resume.message", name: child.display_name)
  end

  def url
    continue_child_questionnaire_session_path(child_id: record.child_id, id: record.id)
  end
end
