# frozen_string_literal: true

require "test_helper"

class ChildPolicyTest < ActiveSupport::TestCase
  test "create? allowed when free account has no children" do
    # subscribed account has 0 children but let's test a free account with room
    account = accounts(:subscribed) # 0 children, premium
    account_user = account_users(:subscribed)

    # Even without premium, 0 children < 1 limit
    account.stub(:premium?, false) do
      policy = ChildPolicy.new(account_user, Child.new)
      assert policy.create?
    end
  end

  test "create? denied when free account at 1 child limit" do
    # accounts(:one) has 2 active children (emma, matteo) — over free limit
    account_user = account_users(:one)

    policy = ChildPolicy.new(account_user, Child.new)
    refute policy.create?
  end

  test "create? allowed when premium account has multiple children" do
    # Create a child for the subscribed (premium) account
    account = accounts(:subscribed)
    account.children.create!(name: "Test", birth_date: 3.months.ago, sex: 1)
    account_user = account_users(:subscribed)

    policy = ChildPolicy.new(account_user, Child.new)
    assert policy.create?
  end

  test "create? denied when premium account at 3 child limit" do
    account = accounts(:subscribed)
    3.times { |i| account.children.create!(name: "Child#{i}", birth_date: i.months.ago, sex: 1) }
    account_user = account_users(:subscribed)

    policy = ChildPolicy.new(account_user, Child.new)
    refute policy.create?
  end

  test "at_children_limit? true when free account at limit" do
    account_user = account_users(:one) # account has 2 active children, free = limit 1

    policy = ChildPolicy.new(account_user, Child.new)
    assert policy.at_children_limit?
  end

  test "at_children_limit? false when under limit" do
    account = accounts(:subscribed)
    account_user = account_users(:subscribed)

    account.stub(:premium?, false) do
      policy = ChildPolicy.new(account_user, Child.new)
      refute policy.at_children_limit?
    end
  end
end
