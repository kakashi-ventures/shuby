require "test_helper"

class Children::MilestoneReminderNotifierTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    @account = @child.account
  end

  test "creates an event when fired" do
    assert_difference "Children::MilestoneReminderNotifier.count", 1 do
      Children::MilestoneReminderNotifier.with(account: @account, record: @child).save!
    end
  end

  test "url deep-links to the development stages timeline" do
    event = Children::MilestoneReminderNotifier.with(account: @account, record: @child).tap(&:save!)
    assert_equal "/children/#{@child.id}/development-stages", event.url
  end

  test "message uses Italian copy with child's display name" do
    event = Children::MilestoneReminderNotifier.with(account: @account, record: @child).tap(&:save!)
    I18n.with_locale(:it) do
      assert_includes event.message, @child.display_name
      assert_includes event.message, "tappa"
    end
  end
end
