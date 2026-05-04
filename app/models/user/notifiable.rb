module User::Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
    has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
    has_many :notification_tokens, dependent: :destroy

    store_accessor :preferences,
      :push_notifications_enabled,
      :email_newsletter_enabled,
      :stage_reminders_enabled
  end

  def push_notifications_enabled=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  def push_notifications_enabled
    value = super
    return true if value.nil?
    value
  end

  # Marketing newsletter — opt-in (off by default per GDPR norms).
  def email_newsletter_enabled=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  def email_newsletter_enabled
    value = super
    return false if value.nil?
    value
  end

  # Reminders for milestone questionnaires + measurement entry — core UX,
  # opt-out (on by default).
  def stage_reminders_enabled=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  def stage_reminders_enabled
    value = super
    return true if value.nil?
    value
  end
end
