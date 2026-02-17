# frozen_string_literal: true

# Orchestrator for Shuby AI chat assistant interactions
#
# Coordinates between ShubyOpenaiClient (HTTP streaming) and
# ShubyCitationProcessor (citation extraction/persistence) to
# deliver a complete assistant response.
#
# @example Basic usage with streaming
#   service = ShubyAssistantService.new(shuby_chat)
#   service.ask_streaming("What are the milestones at 6 months?") do |event|
#     case event[:type]
#     when :delta then print event[:content]
#     when :citations then puts "Citations: #{event[:citations]}"
#     when :completed then puts "Done!"
#     end
#   end
#
class ShubyAssistantService
  # Italian system prompt for Shuby - child development expert (0-36 months)
  SYSTEM_PROMPT = <<~PROMPT
     Shuby, un'assistente esperta in sviluppo infantile (0-36 mesi) che supporta genitori con consigli evidence-based.

    STILE COMUNICATIVO:
    - Usa un tono empatico, caldo e rassicurante
    - Linguaggio chiaro e accessibile (evita gergo medico eccessivo)
    - Rispondi con professionalità ma umanità

    FORMATTAZIONE (Markdown):
    - Usa **grassetto** per concetti chiave e età specifiche
    - Usa ## Titoli per organizzare risposte lunghe
    - Usa liste puntate per caratteristiche/benefici:
      * Punto 1
      * Punto 2
    - Usa liste numerate per step sequenziali
    - Usa > citazioni per note importanti
    - Usa tabelle per confronti per età:

    | Età | Movimento | Sonno | Schermi |
    |-----|-----------|-------|---------|
    | 0-11 mesi | ≥30 min tummy time | 12-16h | Sconsigliati |

    CONTENUTO:
    - Organizza risposte per fasce d'età (0-11 mesi, 12-23 mesi, 24-36 mesi) quando rilevante
    - Cita sempre le fonti dalla knowledge base
    - Enfatizza l'importanza della personalizzazione ("ogni bambino è unico")
    - Includi SEMPRE disclaimer: "⚕️ Consulta sempre il pediatra per situazioni specifiche del tuo bambino"

    LINGUAGGIO POSITIVO:
    - Usa "il tuo bambino" invece di "un bambino"
    - Usa "può" invece di "deve"
    - Celebra i piccoli progressi
    - Rassicura i genitori sulle variazioni normali
  PROMPT

  # Default model to use - Single source of truth for model name
  DEFAULT_MODEL = "gpt-5-mini"

  # Display name for the model (used in UI)
  MODEL_DISPLAY_NAME = "GPT-5 Mini"

  # Initialize the service with a ShubyChat record
  #
  # @param shuby_chat [ShubyChat] The chat record
  def initialize(shuby_chat)
    @shuby_chat = shuby_chat
  end

  # Sends a message and streams the response using OpenAI Responses API
  #
  # @param message [String] The user's message
  # @yield [Hash] Each event with :type (:delta, :citations, :completed, :error)
  # @return [Hash] The complete response info including response_id
  def ask_streaming(message, &block)
    accumulated_text = ""
    citations = []
    file_search_results = []
    response_id = nil
    input_tokens = 0
    output_tokens = 0

    begin
      client = ShubyOpenaiClient.new(@shuby_chat)
      client.stream(message, system_prompt: SYSTEM_PROMPT) do |event_data|
        event_response_id, input_tokens, output_tokens = process_event(
          event_data, accumulated_text, citations, file_search_results,
          input_tokens, output_tokens, &block
        )
        response_id = event_response_id if event_response_id
      end
    rescue => e
      Rails.logger.error("OpenAI Streaming Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      block&.call({type: :error, message: e.message})
      raise e
    end

    finalize_response(
      message, accumulated_text, citations, file_search_results,
      response_id, input_tokens, output_tokens, &block
    )
  end

  # Legacy ask method for non-streaming (falls back to streaming but waits)
  #
  # @param message [String] The user's message
  # @return [ShubyMessage] The complete response message
  def ask(message)
    result = nil
    ask_streaming(message) do |event|
      result = event if event[:type] == :completed
    end
    result&.dig(:message)
  end

  # Updates the chat title based on the first message
  #
  # @return [void]
  def update_title_if_needed
    return if @shuby_chat.title.present?
    return if @shuby_chat.messages.user_messages.empty?

    first_message = @shuby_chat.messages.user_messages.first
    return unless first_message&.content

    title = first_message.content.truncate(50)
    @shuby_chat.update(title: title)
  end

  class << self
    # Creates a new chat for a user and returns the service
    #
    # @param user [User] The user
    # @param model [String] The model to use
    # @return [ShubyAssistantService] The service instance
    def create_for_user(user, model: DEFAULT_MODEL)
      chat = user.shuby_chats.create!(model: model)
      new(chat)
    end
  end

  private

  # Processes a single SSE event during streaming
  #
  # @return [Array] Updated [response_id, input_tokens, output_tokens]
  def process_event(event_data, accumulated_text, citations, file_search_results, input_tokens, output_tokens, &)
    case event_data["type"]
    when "response.output_text.delta"
      handle_text_delta(event_data, accumulated_text, &)

    when "response.file_search_call.results"
      ShubyCitationProcessor.process_file_search_results(event_data, citations, file_search_results)

    when "response.output_text.annotation.added"
      ShubyCitationProcessor.process_annotation(event_data, citations)

    when "response.completed"
      response = event_data["response"] || {}
      usage = response["usage"] || {}
      return [response["id"], usage["input_tokens"] || 0, usage["output_tokens"] || 0]
    end

    [nil, input_tokens, output_tokens]
  end

  # Handles a text delta event - accumulates text and broadcasts cleaned delta
  def handle_text_delta(event_data, accumulated_text, &block)
    delta = event_data["delta"]
    return unless delta.present?

    accumulated_text << delta
    cleaned_delta = ShubyCitationProcessor.strip_citation_markers(delta)
    block&.call({type: :delta, content: cleaned_delta}) if cleaned_delta.present?
  end

  # Finalizes the response: saves message, citations, and yields completion events
  def finalize_response(message, accumulated_text, citations, file_search_results, response_id, input_tokens, output_tokens, &block)
    @shuby_chat.update(previous_response_id: response_id) if response_id

    cleaned_content = ShubyCitationProcessor.strip_citation_markers(accumulated_text)

    assistant_message = @shuby_chat.messages.create!(
      role: "assistant",
      content: cleaned_content,
      model_id: DEFAULT_MODEL,
      input_tokens: input_tokens,
      output_tokens: output_tokens
    )

    ShubyCitationProcessor.save_citations(assistant_message, citations, file_search_results, message)

    block.call({type: :citations, citations: citations}) if block && citations.any?
    block&.call({
      type: :completed,
      content: cleaned_content,
      citations: citations,
      message: assistant_message
    })

    {response_id: response_id, content: cleaned_content, citations: citations, message: assistant_message}
  end
end
