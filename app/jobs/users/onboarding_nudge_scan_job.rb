class Users::OnboardingNudgeScanJob < ApplicationJob
  queue_as :default

  def perform
    Time.use_zone("Europe/Rome") do
      User.where(onboarding_completed_at: window).find_each do |user|
        account = user.personal_account || user.owned_accounts.first
        next if account.nil?
        next if any_measurement_recorded?(account)
        next if already_notified?(user)

        Users::OnboardingNudgeNotifier
          .with(account: account, record: user)
          .deliver([user])
      end
    end
  end

  private

  def window
    3.days.ago.beginning_of_day..2.days.ago.beginning_of_day
  end

  def any_measurement_recorded?(account)
    Measurement.joins(:child).where(children: {account_id: account.id}).exists?
  end

  def already_notified?(user)
    Noticed::Event.where(
      type: "Users::OnboardingNudgeNotifier",
      record_type: "User",
      record_id: user.id
    ).exists?
  end
end
