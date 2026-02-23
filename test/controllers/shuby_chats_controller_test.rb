require "test_helper"

class ShubyChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @chat = shuby_chats(:one)
    sign_in @user
  end

  test "requires authentication" do
    sign_out @user
    get shuby_chats_path
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    get shuby_chats_path
    assert_response :success
    assert_select "h1", /Shuby/
  end

  test "should create shuby_chat" do
    assert_difference("ShubyChat.count") do
      post shuby_chats_path
    end

    assert_redirected_to shuby_chat_path(ShubyChat.last)
  end

  test "should show shuby_chat" do
    get shuby_chat_path(@chat)
    assert_response :success
  end

  test "should not show other user's chat" do
    users(:two)
    other_chat = shuby_chats(:two)

    get shuby_chat_path(other_chat)
    assert_redirected_to shuby_chats_path
  end

  test "should destroy shuby_chat" do
    assert_difference("ShubyChat.count", -1) do
      delete shuby_chat_path(@chat)
    end

    assert_redirected_to shuby_chats_path
  end

  test "should not destroy other user's chat" do
    other_chat = shuby_chats(:two)

    assert_no_difference("ShubyChat.count") do
      delete shuby_chat_path(other_chat)
    end

    assert_redirected_to shuby_chats_path
  end

  test "message action requires valid message" do
    post message_shuby_chat_path(@chat), params: {message: ""}

    # With empty message, controller redirects back to chat with alert
    assert_redirected_to shuby_chat_path(@chat)
  end

  test "message action with valid message" do
    # This test would require mocking the OpenAI API
    # For now, we skip the actual API call test
    skip "Requires OpenAI API mocking"
  end

  # --- Rate Limiting Tests ---

  test "show displays remaining messages count for free user" do
    get shuby_chat_path(@chat)
    assert_response :success
    assert_select "p", /rimast[oiae]/i
  end

  test "message action blocked via HTML redirect when at limit" do
    fill_to_limit(@user)

    post message_shuby_chat_path(@chat), params: {message: "One more message"}

    assert_redirected_to shuby_chat_path(@chat)
    assert_equal I18n.t("shuby_chats.rate_limit.reached"), flash[:alert]
  end

  test "message action blocked via Turbo Stream when at limit" do
    fill_to_limit(@user)

    post message_shuby_chat_path(@chat),
      params: {message: "One more message"},
      headers: {"Accept" => "text/vnd.turbo-stream.html"}

    assert_response :success
    assert_includes response.body, I18n.t("shuby_chats.rate_limit.reached_title")
  end

  test "message action allowed when under limit" do
    assert_difference("ShubyMessage.count") do
      post message_shuby_chat_path(@chat),
        params: {message: "Hello Shuby"},
        headers: {"Accept" => "text/vnd.turbo-stream.html"}
    end
  end

  test "show renders rate limit CTA when at limit" do
    fill_to_limit(@user)

    get shuby_chat_path(@chat)
    assert_response :success
    assert_select "#message_form" do
      assert_select "a[href=?]", pricing_path
    end
  end

  private

  def fill_to_limit(user)
    chat = user.shuby_chats.create!(model: "gpt-4o-mini")
    existing = user.chat_messages_sent_this_month
    remaining = User::ChatRateLimit::FREE_MONTHLY_MESSAGE_LIMIT - existing
    remaining.times { |i| chat.messages.create!(role: "user", content: "Msg #{i}") }
  end
end
