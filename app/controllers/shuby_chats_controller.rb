# frozen_string_literal: true

# Controller for Shuby chat assistant
# Handles conversation management and messaging via Turbo Streams
class ShubyChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shuby_chat, only: [:show, :destroy, :message]
  before_action :check_chat_rate_limit, only: [:message]

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
    @chat_rate_limited = current_user.chat_rate_limited?
    @messages_remaining = current_user.chat_messages_remaining
  end

  # POST /shuby
  # Creates a new conversation and redirects to it
  def create
    @shuby_chat = current_user.shuby_chats.create!(
      model: params[:model] || ShubyAssistantService::DEFAULT_MODEL,
      account: current_account,
      child: current_child
    )

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
        streams << turbo_stream.append("messages", partial: "shuby_chats/message", locals: {message: user_message, streamed: true})

        # Append assistant placeholder
        streams << turbo_stream.append("messages", partial: "shuby_chats/assistant_message_placeholder", locals: {message_id: streaming_message_id})

        # Reset the form (with updated remaining count)
        streams << if current_user.chat_rate_limited?
          turbo_stream.replace("message_form", partial: "shuby_chats/rate_limit_reached")
        else
          turbo_stream.replace("message_form", partial: "shuby_chats/message_form", locals: {shuby_chat: @shuby_chat, messages_remaining: current_user.chat_messages_remaining})
        end

        render turbo_stream: streams
      end
      format.html { redirect_to shuby_chat_path(@shuby_chat) }
    end

    # Process the AI response in a background thread and stream via ActionCable
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        ShubyBroadcastService.new(@shuby_chat).stream_ai_response(user_message_content, streaming_message_id)
      end
    end
  end

  private

  # Blocks message submission if the user has hit their monthly limit
  #
  # @return [void]
  def check_chat_rate_limit
    return unless current_user.chat_rate_limited?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "message_form",
          partial: "shuby_chats/rate_limit_reached"
        )
      end
      format.html { redirect_to shuby_chat_path(@shuby_chat), alert: t("shuby_chats.rate_limit.reached") }
    end
  end

  # Sets the shuby_chat from params
  #
  # @return [void]
  def set_shuby_chat
    @shuby_chat = current_user.shuby_chats.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to shuby_chats_path, alert: t("shuby_chats.not_found")
  end
end
