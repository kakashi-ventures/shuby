class Children::QuestionnaireResumeScanJob < ApplicationJob
  queue_as :default

  STALE_THRESHOLD = 3.days

  def perform
    Time.use_zone("Europe/Rome") do
      QuestionnaireSession.in_progress
        .where("started_at < ?", STALE_THRESHOLD.ago)
        .where.not(id: already_notified_session_ids)
        .includes(child: :account).find_each do |session|
          account = session.child.account
          recipients = account.users.select(&:stage_reminders_enabled)
          next if recipients.empty?

          Children::QuestionnaireResumeNotifier
            .with(account: account, record: session)
            .deliver(recipients)
        end
    end
  end

  private

  def already_notified_session_ids
    Noticed::Event.where(
      type: "Children::QuestionnaireResumeNotifier",
      record_type: "QuestionnaireSession"
    ).pluck(:record_id)
  end
end
