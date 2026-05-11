require "test_helper"

class Children::MilestoneReminderScanJobTest < ActiveJob::TestCase
  setup do
    @child = children(:sophia) # 2mo, has uncompleted milestones
    @account = @child.account
    @account.users.each { |u| u.update!(stage_reminders_enabled: true) }
  end

  test "skips children notified within the cooldown window" do
    Children::MilestoneReminderNotifier.with(account: @account, record: @child).save!
    assert_no_difference -> { events_for(@child).count } do
      Children::MilestoneReminderScanJob.perform_now
    end
  end

  test "skips children with a recently completed questionnaire" do
    questionnaire_sessions(:completed_session).update!(completed_at: 2.days.ago)
    assert_no_difference -> { events_for(@child).count } do
      Children::MilestoneReminderScanJob.perform_now
    end
  end

  test "skips when all account recipients disabled stage_reminders_enabled" do
    @account.users.each { |u| u.update!(stage_reminders_enabled: false) }
    assert_no_difference -> { events_for(@child).count } do
      Children::MilestoneReminderScanJob.perform_now
    end
  end

  private

  def events_for(child)
    Noticed::Event.where(
      type: "Children::MilestoneReminderNotifier",
      record_type: "Child",
      record_id: child.id
    )
  end
end
