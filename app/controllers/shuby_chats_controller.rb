# frozen_string_literal: true

require "ostruct"

# Controller for Shuby chat assistant
# Handles conversation management and messaging via Turbo Streams
class ShubyChatsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_shuby_chat, only: [:show, :destroy, :message]

  # GET /shuby
  # Lists all conversations for the current user
  def index
    @shuby_chats = current_user.shuby_chats.recent.with_messages
  end

  # GET /shuby/:id
  # Shows a specific conversation
  def show
    # Only show user and assistant messages (exclude tool/system messages)
    @messages = @shuby_chat.messages.chronological.where(role: %w[user assistant]).includes(:tool_calls)
  end

  # POST /shuby
  # Creates a new conversation and redirects to it
  def create
    @shuby_chat = current_user.shuby_chats.create!(model: params[:model] || ShubyAssistantService::DEFAULT_MODEL)

    respond_to do |format|
      format.html { redirect_to shuby_chat_path(@shuby_chat) }
      format.turbo_stream { redirect_to shuby_chat_path(@shuby_chat) }
    end
  end

  # DELETE /shuby/:id
  # Deletes a conversation
  def destroy
    @shuby_chat.destroy

    respond_to do |format|
      format.html { redirect_to shuby_chats_path, notice: t(".destroyed"), status: :see_other }
      format.turbo_stream { redirect_to shuby_chats_path, status: :see_other }
    end
  end

  # POST /shuby/:id/message
  # Sends a message and streams the AI response via Turbo Streams
  def message
    user_message_content = params[:message]&.strip

    if user_message_content.blank?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "shuby_chats/message_form",
            locals: {shuby_chat: @shuby_chat, error: t(".blank_message")}
          )
        end
        format.html { redirect_to shuby_chat_path(@shuby_chat), alert: t(".blank_message") }
      end
      return
    end

    # Save the user message
    user_message = @shuby_chat.messages.create!(role: "user", content: user_message_content)

    # Generate unique message ID for the streaming assistant message
    streaming_message_id = "assistant_message_#{SecureRandom.hex(8)}"

    respond_to do |format|
      format.turbo_stream do
        # Remove welcome message if present
        streams = []
        streams << turbo_stream.remove("welcome-message")

        # Append user message
        streams << turbo_stream.append("messages", partial: "shuby_chats/message", locals: {message: user_message})

        # Append assistant placeholder
        streams << turbo_stream.append("messages", partial: "shuby_chats/assistant_message_placeholder", locals: {message_id: streaming_message_id})

        # Reset the form
        streams << turbo_stream.replace("message_form", partial: "shuby_chats/message_form", locals: {shuby_chat: @shuby_chat})

        render turbo_stream: streams
      end
      format.html { redirect_to shuby_chat_path(@shuby_chat) }
    end

    # Process the AI response in a background thread and stream via ActionCable
    Thread.new do
      stream_ai_response(user_message_content, streaming_message_id)
    end
  end

  private

  # Sets the shuby_chat from params
  #
  # @return [void]
  def set_shuby_chat
    @shuby_chat = current_user.shuby_chats.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to shuby_chats_path, alert: t("shuby_chats.not_found")
  end

  # Streams the AI response via Turbo Streams
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
          # Broadcast final message with citations
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
    ensure
      ActiveRecord::Base.connection_pool.release_connection
    end
  end

  # Broadcasts a streaming content update
  #
  # @param message_id [String] The DOM ID of the message element
  # @param content [String] The accumulated content so far
  def broadcast_streaming_update(message_id, content)
    Turbo::StreamsChannel.broadcast_replace_to(
      "shuby_chat_#{@shuby_chat.id}",
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
      "shuby_chat_#{@shuby_chat.id}",
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
      "shuby_chat_#{@shuby_chat.id}",
      target: message_id,
      partial: "shuby_chats/error_message",
      locals: {message_id: message_id, error: error_text}
    )
  end
end
