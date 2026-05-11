class Children::MeasurementReminderScanJob < ApplicationJob
  queue_as :default

  COOLDOWN = 7.days
  TRACKED_TYPES = %w[weight height head_circumference].freeze

  def perform
    Time.use_zone("Europe/Rome") do
      Child.active.includes(:account).find_each do |child|
        next if recently_notified?(child)
        next unless any_measurement_stale?(child)

        recipients = child.account.users.select(&:stage_reminders_enabled)
        next if recipients.empty?

        Children::MeasurementReminderNotifier
          .with(account: child.account, record: child)
          .deliver(recipients)
      end
    end
  end

  private

  def recently_notified?(child)
    Noticed::Event.where(
      type: "Children::MeasurementReminderNotifier",
      record_type: "Child",
      record_id: child.id
    ).where(created_at: COOLDOWN.ago..).exists?
  end

  def any_measurement_stale?(child)
    age = child.questionnaire_age_in_months
    TRACKED_TYPES.any? do |type|
      m = child.latest_measurement(type)
      m.nil? || m.stale?(age)
    end
  end
end
