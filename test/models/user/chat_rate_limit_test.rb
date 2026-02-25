require "test_helper"

class User::ChatRateLimitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @chat = shuby_chats(:one)
  end

  test "chat_messages_sent_this_month counts only user role messages" do
    # Fixture has 1 user message and 1 assistant message for this user's chat
    count = @user.chat_messages_sent_this_month
    user_messages = ShubyMessage.joins(:chat)
      .where(shuby_chats: {user_id: @user.id})
      .where(role: "user")
      .where(created_at: Time.current.beginning_of_month..)
      .count

    assert_equal user_messages, count
  end

  test "chat_messages_sent_this_month excludes messages from previous months" do
    # Create a message from last month
    old_chat = @user.shuby_chats.create!(model: "gpt-4o-mini", account: accounts(:one))
    old_msg = old_chat.messages.create!(role: "user", content: "Old message")
    old_msg.update_column(:created_at, 1.month.ago)

    count_before = @user.chat_messages_sent_this_month

    # Create a message this month
    @chat.messages.create!(role: "user", content: "New message")

    assert_equal count_before + 1, @user.chat_messages_sent_this_month
  end

  test "chat_messages_sent_this_month excludes other users messages" do
    other_user = users(:two)
    other_chat = shuby_chats(:two)
    other_chat.messages.create!(role: "user", content: "Other user message")

    # The other user's message should not affect this user's count
    count = @user.chat_messages_sent_this_month
    other_count = other_user.chat_messages_sent_this_month

    assert other_count > 0, "Other user should have messages"
    # Counts should be independent
    assert_equal ShubyMessage.joins(:chat)
      .where(shuby_chats: {user_id: @user.id})
      .where(role: "user")
      .where(created_at: Time.current.beginning_of_month..)
      .count, count
  end

  test "chat_rate_limited? is false when under limit" do
    refute @user.chat_rate_limited?
  end

  test "chat_rate_limited? is true when at limit" do
    # Create enough messages to hit the limit
    chat = @user.shuby_chats.create!(model: "gpt-4o-mini", account: accounts(:one))
    existing = @user.chat_messages_sent_this_month
    (User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT - existing).times do |i|
      chat.messages.create!(role: "user", content: "Message #{i}")
    end

    assert @user.chat_rate_limited?
  end

  test "chat_messages_remaining returns correct count" do
    existing = @user.chat_messages_sent_this_month
    expected = User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT - existing

    assert_equal expected, @user.chat_messages_remaining
  end

  test "chat_messages_remaining never goes below zero" do
    chat = @user.shuby_chats.create!(model: "gpt-4o-mini", account: accounts(:one))
    existing = @user.chat_messages_sent_this_month
    # Create more than the limit
    (User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT - existing + 5).times do |i|
      chat.messages.create!(role: "user", content: "Message #{i}")
    end

    assert_equal 0, @user.chat_messages_remaining
  end

  test "premium user is never rate limited" do
    # Stub the premium check
    @user.stub(:chat_premium?, true) do
      # Even with many messages, premium user is not rate limited
      chat = @user.shuby_chats.create!(model: "gpt-4o-mini", account: accounts(:one))
      existing = @user.chat_messages_sent_this_month
      (User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT - existing).times do |i|
        chat.messages.create!(role: "user", content: "Message #{i}")
      end

      refute @user.chat_rate_limited?
    end
  end

  test "premium user gets infinity remaining messages" do
    @user.stub(:chat_premium?, true) do
      assert_equal Float::INFINITY, @user.chat_messages_remaining
    end
  end

  test "chat_premium? returns false for free user" do
    refute @user.chat_premium?
  end

  test "FREE_MONTHLY_MESSAGE_LIMIT is 30" do
    assert_equal 30, User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT
  end
end
