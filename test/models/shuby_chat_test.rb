require "test_helper"

class ShubyChatTest < ActiveSupport::TestCase
  setup do
    @chat = shuby_chats(:one)
    @user = users(:one)
  end

  test "valid chat" do
    assert @chat.valid?
  end

  test "invalid without model" do
    @chat.model = nil
    refute @chat.valid?
    assert_not_nil @chat.errors[:model]
  end

  test "invalid without user" do
    @chat.user = nil
    refute @chat.valid?
  end

  test "belongs to user" do
    assert_respond_to @chat, :user
    assert_equal @user, @chat.user
  end

  test "has many messages" do
    assert_respond_to @chat, :messages
    assert_includes @chat.messages, shuby_messages(:user_message)
  end

  test "display_title returns title when present" do
    @chat.title = "Custom Title"
    assert_equal "Custom Title", @chat.display_title
  end

  test "display_title returns first message preview when no title" do
    @chat.title = nil
    assert_includes @chat.display_title, "What are the milestones"
  end

  test "display_title returns New Chat when empty" do
    chat = @user.shuby_chats.create!(model: "gpt-4o-mini")
    # Match English "New Chat" or Italian "Nuova Chat"
    assert_match(/New Chat|Nuova Chat/i, chat.display_title)
  end

  test "recent scope orders by updated_at desc" do
    # Create chats with explicit different timestamps to test ordering
    old_chat = @user.shuby_chats.create!(model: "gpt-4o-mini")
    old_chat.update_column(:updated_at, 1.day.ago)

    new_chat = @user.shuby_chats.create!(model: "gpt-4o-mini")
    new_chat.update_column(:updated_at, Time.current)

    recent_chats = @user.shuby_chats.recent.to_a

    # The most recently updated chat should come first
    assert_equal new_chat.id, recent_chats.first.id
    assert recent_chats.index(new_chat) < recent_chats.index(old_chat)
  end

  test "destroys dependent messages" do
    assert_difference "ShubyMessage.count", -@chat.messages.count do
      @chat.destroy
    end
  end
end
