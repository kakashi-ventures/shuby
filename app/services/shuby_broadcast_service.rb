# frozen_string_literal: true

# Service for broadcasting Shuby AI chat responses via Turbo Streams
#
# Extracts broadcast + streaming logic from ShubyChatsController
# for Single Responsibility compliance.
#
# @example Usage in a background thread
#   Thread.new do
#     ShubyBroadcastService.new(shuby_chat).stream_ai_response(user_message, streaming_message_id)
#   end
#
class ShubyBroadcastService
  def initialize(shuby_chat)
    @shuby_chat = shuby_chat
  end

  # Streams the AI response via Turbo Streams
  #
  # Creates a ShubyAssistantService, processes streaming events,
  # and broadcasts updates to the chat channel.
  #
  # @param user_message [String] The user's message
  # @param streaming_message_id [String] The DOM ID for the streaming message
  def stream_ai_response(user_message, streaming_message_id)
    service = ShubyAssistantService.new(@shuby_chat)
    accumulated_content = ""

    begin
      service.ask_streaming(user_message) do |event|
        case event[:type]
        when :delta
          accumulated_content += event[:content]
          broadcast_streaming_update(streaming_message_id, accumulated_content)

        when :completed
          broadcast_final_message(streaming_message_id, event[:message])
          service.update_title_if_needed

        when :error
          broadcast_error(streaming_message_id, event[:message])
        end
      end
    rescue => e
      Rails.logger.error("Shuby streaming error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      broadcast_error(streaming_message_id, I18n.t("shuby_chats.processing_error"))
    end
  end

  private

  # Broadcasts a streaming content update
  #
  # @param message_id [String] The DOM ID of the message element
  # @param content [String] The accumulated content so far
  def broadcast_streaming_update(message_id, content)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: message_id,
      partial: "shuby_chats/assistant_message_streaming",
      locals: {message_id: message_id, content: content}
    )
  end

  # Broadcasts the final complete message
  #
  # @param message_id [String] The DOM ID to replace
  # @param message [ShubyMessage] The complete message
  def broadcast_final_message(message_id, message)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: message_id,
      partial: "shuby_chats/message",
      locals: {message: message, message_id: message_id}
    )
  end

  # Broadcasts an error message
  #
  # @param message_id [String] The DOM ID to replace
  # @param error_text [String] The error message
  def broadcast_error(message_id, error_text)
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_key,
      target: message_id,
      partial: "shuby_chats/error_message",
      locals: {message_id: message_id, error: error_text}
    )
  end

  # @return [String] The Turbo Streams channel key for this chat
  def stream_key
    "shuby_chat_#{@shuby_chat.id}"
  end
end
