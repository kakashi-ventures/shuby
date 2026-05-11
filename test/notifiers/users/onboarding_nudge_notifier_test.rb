require "test_helper"

class Users::OnboardingNudgeNotifierTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @account = accounts(:one)
  end

  test "creates an event when fired" do
    assert_difference "Users::OnboardingNudgeNotifier.count", 1 do
      Users::OnboardingNudgeNotifier.with(account: @account, record: @user).save!
    end
  end

  test "message falls back to generic when account has no active child" do
    empty_account = accounts(:invited)
    event = Users::OnboardingNudgeNotifier.with(account: empty_account, record: users(:invited)).tap(&:save!)
    I18n.with_locale(:it) do
      assert_includes event.message, "tuo figlio"
    end
  end

  test "message uses the first active child's name when available" do
    event = Users::OnboardingNudgeNotifier.with(account: @account, record: @user).tap(&:save!)
    first_child = @account.children.active.first
    I18n.with_locale(:it) do
      assert_includes event.message, first_child.display_name
    end
  end
end
