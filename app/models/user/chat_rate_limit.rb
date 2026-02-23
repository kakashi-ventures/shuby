# frozen_string_literal: true

module User::ChatRateLimit
  extend ActiveSupport::Concern

  FREE_MONTHLY_MESSAGE_LIMIT = 30

  # Counts user messages sent in the current calendar month across all chats
  #
  # @return [Integer]
  def chat_messages_sent_this_month
    ShubyMessage.joins(:chat)
      .where(shuby_chats: {user_id: id})
      .where(role: "user")
      .where(created_at: Time.current.beginning_of_month..)
      .count
  end

  # Returns remaining messages for the current month
  #
  # @return [Integer, Float::INFINITY] remaining count, or infinity for premium users
  def chat_messages_remaining
    return Float::INFINITY if chat_premium?

    [FREE_MONTHLY_MESSAGE_LIMIT - chat_messages_sent_this_month, 0].max
  end

  # Checks if the user has hit their monthly chat message limit
  #
  # @return [Boolean]
  def chat_rate_limited?
    return false if chat_premium?

    chat_messages_sent_this_month >= FREE_MONTHLY_MESSAGE_LIMIT
  end

  # Checks if the user has a premium subscription
  #
  # @return [Boolean]
  def chat_premium?
    personal_account&.payment_processor&.subscribed? || false
  end
end
