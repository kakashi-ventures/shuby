require "test_helper"

class Users::OnboardingNudgeScanJobTest < ActiveJob::TestCase
  setup do
    @user = users(:two)
    Time.use_zone("Europe/Rome") do
      @user.update!(onboarding_completed_at: 2.days.ago.beginning_of_day - 12.hours)
    end
  end

  test "fires for a user 2-3 days post-signup whose personal account has no measurements" do
    Users::OnboardingNudgeScanJob.perform_now
    assert events_for(@user).exists?
  end

  test "skips users outside the 2-3 day window" do
    @user.update!(onboarding_completed_at: 5.days.ago)
    Users::OnboardingNudgeScanJob.perform_now
    refute events_for(@user).exists?
  end

  test "fires only once per user lifetime" do
    account = @user.personal_account || @user.owned_accounts.first
    Users::OnboardingNudgeNotifier.with(account: account, record: @user).save!
    assert_no_difference -> { events_for(@user).count } do
      Users::OnboardingNudgeScanJob.perform_now
    end
  end

  private

  def events_for(user)
    Noticed::Event.where(
      type: "Users::OnboardingNudgeNotifier",
      record_type: "User",
      record_id: user.id
    )
  end
end
