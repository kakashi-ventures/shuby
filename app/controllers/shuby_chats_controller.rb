# frozen_string_literal: true

# Controller for Shuby chat assistant.
# Handles conversation management and messaging via Turbo Streams.
#
# Routing model (post-Figma alignment):
#   GET  /shuby           → #index    — renders the current chat surface
#                                       (finds or creates the user's most
#                                       recent chat, then renders :show).
#   GET  /shuby/history   → #history  — linear list of past conversations.
#   POST /shuby           → #create   — explicitly start a new conversation.
#   GET  /shuby/:id       → #show     — render a specific conversation.
#   POST /shuby/:id/message → #message — send a message and stream the AI reply.
#   DELETE /shuby/:id     → #destroy  — delete a conversation.
class ShubyChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shuby_chat, only: [:show, :destroy, :message]
  before_action :check_chat_rate_limit, only: [:message]

  # GET /shuby
  # Renders the chat surface for the user's current (most recent) chat,
  # creating one on demand if none exists yet.
  def index
    @shuby_chat = find_or_create_current_chat
    load_show_assigns(@shuby_chat)
    render :show
  end

  # GET /shuby/history
  # Linear list of past conversations. Chats with no user/assistant
  # messages are hidden — they're stub chats that haven't actually been used.
  def history
    @shuby_chats = current_user.shuby_chats.recent.with_messages.reject(&:empty?)
  end

  # GET /shuby/:id
  def show
    load_show_assigns(@shuby_chat)
  end

  # POST /shuby
  # Starts a fresh conversation. If the user already has a current empty
  # chat, that one is reused instead of creating another — keeps the
  # "+ new" header button idempotent and avoids polluting history with
  # stub chats when the user taps it repeatedly.
  def create
    @shuby_chat = reuse_empty_chat_or_create

    respond_to do |format|
      format.html { redirect_to shuby_chat_path(@shuby_chat) }
      format.turbo_stream { redirect_to shuby_chat_path(@shuby_chat) }
    end
  end

  # DELETE /shuby/:id
  # Deletes a conversation and returns to the history list.
  def destroy
    @shuby_chat.destroy

    respond_to do |format|
      format.html { redirect_to history_shuby_chats_path, notice: t(".destroyed"), status: :see_other }
      format.turbo_stream { redirect_to history_shuby_chats_path, status: :see_other }
    end
  end

  # POST /shuby/:id/message
  # Sends a message and streams the AI response via Turbo Streams.
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

    user_message = @shuby_chat.messages.create!(role: "user", content: user_message_content)
    streaming_message_id = "assistant_message_#{SecureRandom.hex(8)}"

    respond_to do |format|
      format.turbo_stream do
        streams = []
        streams << turbo_stream.append("messages", partial: "shuby_chats/message", locals: {message: user_message, streamed: true})
        streams << turbo_stream.append("messages", partial: "shuby_chats/assistant_message_placeholder", locals: {message_id: streaming_message_id})

        streams << if current_user.chat_rate_limited?
          turbo_stream.replace("message_form", partial: "shuby_chats/rate_limit_reached")
        else
          turbo_stream.replace("message_form", partial: "shuby_chats/message_form",
            locals: {shuby_chat: @shuby_chat, messages_remaining: current_user.chat_messages_remaining})
        end

        render turbo_stream: streams
      end
      format.html { redirect_to shuby_chat_path(@shuby_chat) }
    end

    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        ShubyBroadcastService.new(@shuby_chat).stream_ai_response(user_message_content, streaming_message_id)
      end
    end
  end

  private

  # Returns the user's most recent chat, or creates one if none exists.
  def find_or_create_current_chat
    current_user.shuby_chats.recent.first || build_new_chat
  end

  # Reuses the user's most recent chat when it's still empty; otherwise
  # creates a new one. Empty = no user/assistant messages yet.
  def reuse_empty_chat_or_create
    most_recent = current_user.shuby_chats.recent.first
    return most_recent if most_recent&.empty?

    build_new_chat
  end

  def build_new_chat
    current_user.shuby_chats.create!(
      model: params[:model] || ShubyAssistantService::DEFAULT_MODEL,
      account: current_account,
      child: current_child
    )
  end

  # Sets up the instance vars used by the chat surface (:show template).
  def load_show_assigns(chat)
    @messages = chat.messages.chronological.where(role: %w[user assistant]).includes(:tool_calls)
    @chat_rate_limited = current_user.chat_rate_limited?
    @messages_remaining = current_user.chat_messages_remaining
  end

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

  def set_shuby_chat
    @shuby_chat = current_user.shuby_chats.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to shuby_chats_path, alert: t("shuby_chats.not_found")
  end
end
