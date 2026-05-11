require "test_helper"

class Children::QuestionnaireResumeNotifierTest < ActiveSupport::TestCase
  setup do
    @session = questionnaire_sessions(:in_progress_session)
    @child = @session.child
    @account = @child.account
  end

  test "creates an event when fired" do
    assert_difference "Children::QuestionnaireResumeNotifier.count", 1 do
      Children::QuestionnaireResumeNotifier.with(account: @account, record: @session).save!
    end
  end

  test "url deep-links to continue the questionnaire session" do
    event = Children::QuestionnaireResumeNotifier.with(account: @account, record: @session).tap(&:save!)
    assert_equal "/children/#{@child.id}/questionnaires/#{@session.id}/continue", event.url
  end

  test "message uses Italian copy with child's display name" do
    event = Children::QuestionnaireResumeNotifier.with(account: @account, record: @session).tap(&:save!)
    I18n.with_locale(:it) do
      assert_includes event.message, @child.display_name
      assert_includes event.message.downcase, "questionario"
    end
  end
end
