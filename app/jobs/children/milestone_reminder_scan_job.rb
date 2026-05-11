class Children::MilestoneReminderScanJob < ApplicationJob
  queue_as :default

  COOLDOWN = 7.days

  def perform
    Time.use_zone("Europe/Rome") do
      Child.active.includes(:account).find_each do |child|
        next if recently_notified?(child)
        next if engaged_recently?(child)

        result = DailyMilestoneService.call(child)
        next if result[:milestone].nil?

        recipients = child.account.users.select(&:stage_reminders_enabled)
        next if recipients.empty?

        Children::MilestoneReminderNotifier
          .with(account: child.account, record: child)
          .deliver(recipients)
      end
    end
  end

  private

  def recently_notified?(child)
    Noticed::Event.where(
      type: "Children::MilestoneReminderNotifier",
      record_type: "Child",
      record_id: child.id
    ).where(created_at: COOLDOWN.ago..).exists?
  end

  def engaged_recently?(child)
    child.questionnaire_sessions.completed
      .where(completed_at: COOLDOWN.ago..).exists?
  end
end
