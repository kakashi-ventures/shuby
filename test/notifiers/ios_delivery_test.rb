require "test_helper"

class IosDeliveryTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @user.update!(time_zone: "Europe/Rome", preferences: {})
  end

  test "IOS_ADAPTER is :test in the test environment" do
    assert_equal :test, ApplicationNotifier::IOS_ADAPTER
  end

  test "deliverable_to? returns false during quiet hours" do
    travel_to Time.zone.parse("2025-06-15 22:30:00 +0200") do
      refute ApplicationNotifier.deliverable_to?(@user)
    end
  end

  test "deliverable_to? returns true during business hours" do
    travel_to Time.zone.parse("2025-06-15 11:00:00 +0200") do
      assert ApplicationNotifier.deliverable_to?(@user)
    end
  end

  test "deliverable_to? defaults to Europe/Rome when time_zone is nil" do
    @user.update!(time_zone: nil)
    travel_to Time.zone.parse("2025-06-15 03:00:00 +0200") do
      refute ApplicationNotifier.deliverable_to?(@user)
    end
  end

  test "push_allowed? returns false when push_notifications_enabled is off" do
    @user.update!(push_notifications_enabled: false)
    travel_to Time.zone.parse("2025-06-15 11:00:00 +0200") do
      refute ApplicationNotifier.new.push_allowed?(@user)
    end
  end

  test "push_allowed? returns false when global kill switch is off" do
    original = Rails.application.config.x.push_notifications_enabled
    Rails.application.config.x.push_notifications_enabled = false
    travel_to Time.zone.parse("2025-06-15 11:00:00 +0200") do
      refute ApplicationNotifier.new.push_allowed?(@user)
    end
  ensure
    Rails.application.config.x.push_notifications_enabled = original
  end

  test "push_allowed? returns true when all conditions met" do
    travel_to Time.zone.parse("2025-06-15 11:00:00 +0200") do
      assert ApplicationNotifier.new.push_allowed?(@user)
    end
  end
end
