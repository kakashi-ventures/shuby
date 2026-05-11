require "test_helper"

class Children::MeasurementReminderScanJobTest < ActiveJob::TestCase
  setup do
    @child = children(:matteo) # 12mo, no measurements ⇒ stale
    @account = @child.account
    @account.users.each { |u| u.update!(stage_reminders_enabled: true) }
  end

  test "fires for a child with no measurements" do
    Children::MeasurementReminderScanJob.perform_now
    assert events_for(@child).exists?
  end

  test "skips children notified within the cooldown window" do
    Children::MeasurementReminderNotifier.with(account: @account, record: @child).save!
    assert_no_difference -> { events_for(@child).count } do
      Children::MeasurementReminderScanJob.perform_now
    end
  end

  test "fires again after the cooldown window expires" do
    travel_to(8.days.ago) do
      Children::MeasurementReminderNotifier.with(account: @account, record: @child).save!
    end
    assert_difference -> { events_for(@child).count }, 1 do
      Children::MeasurementReminderScanJob.perform_now
    end
  end

  test "skips when all account recipients disabled stage_reminders_enabled" do
    @account.users.each { |u| u.update!(stage_reminders_enabled: false) }
    assert_no_difference -> { events_for(@child).count } do
      Children::MeasurementReminderScanJob.perform_now
    end
  end

  test "skips inactive children" do
    inactive = children(:marco_inactive)
    Children::MeasurementReminderScanJob.perform_now
    refute events_for(inactive).exists?
  end

  private

  def events_for(child)
    Noticed::Event.where(
      type: "Children::MeasurementReminderNotifier",
      record_type: "Child",
      record_id: child.id
    )
  end
end
