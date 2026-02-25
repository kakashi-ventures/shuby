# frozen_string_literal: true

# Model for Shuby chat conversations
#
# @example Create a new chat for a user
#   chat = current_user.shuby_chats.create!(model: "gpt-5-mini")
#   chat.to_llm.ask("What is child development?")
#
class ShubyChat < ApplicationRecord
  acts_as_chat message_class: "ShubyMessage", tool_call_class: "ShubyToolCall"

  belongs_to :user
  belongs_to :account
  belongs_to :child, optional: true

  validates :model, presence: true
  validate :child_belongs_to_account

  # RubyLLM expects model_id, but we use model column
  # Alias methods for compatibility
  alias_attribute :model_id, :model

  scope :recent, -> { order(updated_at: :desc) }
  scope :with_messages, -> { includes(:messages) }

  # Generates a title from the first user message if not set
  #
  # @return [String] The chat title
  def display_title
    title.presence || first_user_message_preview || I18n.t("shuby_chats.default_title")
  end

  private

  def child_belongs_to_account
    return unless child_id.present? && account_id.present?
    return if child.account_id == account_id

    errors.add(:child, :invalid)
  end

  # Extracts preview from the first user message
  #
  # @return [String, nil] First 50 characters of the first user message
  def first_user_message_preview
    first_message = messages.find_by(role: "user")
    return nil unless first_message&.content

    first_message.content.truncate(50)
  end
end
