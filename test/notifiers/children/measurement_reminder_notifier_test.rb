require "test_helper"

class Children::MeasurementReminderNotifierTest < ActiveSupport::TestCase
  setup do
    @child = children(:sophia)
    @account = @child.account
  end

  test "creates an event when fired" do
    assert_difference "Children::MeasurementReminderNotifier.count", 1 do
      Children::MeasurementReminderNotifier.with(account: @account, record: @child).save!
    end
  end

  test "url deep-links to the child's measurements page" do
    event = Children::MeasurementReminderNotifier.with(account: @account, record: @child).tap(&:save!)
    assert_equal "/children/#{@child.id}/measurements", event.url
  end

  test "message uses Italian copy with child's display name" do
    event = Children::MeasurementReminderNotifier.with(account: @account, record: @child).tap(&:save!)
    I18n.with_locale(:it) do
      assert_includes event.message, @child.display_name
      assert_includes event.message, "misurazioni"
    end
  end
end
