require "test_helper"

class Children::QuestionnaireResumeScanJobTest < ActiveJob::TestCase
  setup do
    @session = questionnaire_sessions(:past_in_progress_session) # started 2 weeks ago, in_progress
    @account = @session.child.account
    @account.users.each { |u| u.update!(stage_reminders_enabled: true) }
  end

  test "fires for in-progress sessions older than 3 days" do
    Children::QuestionnaireResumeScanJob.perform_now
    assert events_for(@session).exists?
  end

  test "does not fire for fresh in-progress sessions" do
    fresh = questionnaire_sessions(:in_progress_session) # started 1 day ago
    Children::QuestionnaireResumeScanJob.perform_now
    refute events_for(fresh).exists?
  end

  test "fires only once per session lifetime" do
    Children::QuestionnaireResumeNotifier.with(account: @account, record: @session).save!
    assert_no_difference -> { events_for(@session).count } do
      Children::QuestionnaireResumeScanJob.perform_now
    end
  end

  test "skips when all account recipients disabled stage_reminders_enabled" do
    @account.users.each { |u| u.update!(stage_reminders_enabled: false) }
    assert_no_difference -> { events_for(@session).count } do
      Children::QuestionnaireResumeScanJob.perform_now
    end
  end

  private

  def events_for(session)
    Noticed::Event.where(
      type: "Children::QuestionnaireResumeNotifier",
      record_type: "QuestionnaireSession",
      record_id: session.id
    )
  end
end
