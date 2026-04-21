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
  include Specialists

  # Italian system prompt for Shuby - child development expert (0-36 months)
  BASE_SYSTEM_PROMPT = <<~PROMPT
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

    SITUAZIONI DI EMERGENZA:
    Se l'utente descrive sintomi di emergenza, SEMPRE:
    1. Consiglia IMMEDIATAMENTE di chiamare il 112 o recarsi al Pronto Soccorso
    2. NON fornire consigli medici specifici per emergenze
    3. Rassicura il genitore e ricorda l'importanza di agire rapidamente

    Sintomi di emergenza includono:
    - Febbre ≥38°C in neonati sotto i 3 mesi (qualsiasi febbre nei neonati è un'emergenza)
    - Febbre alta >40°C nei bambini più grandi
    - Difficoltà respiratorie, cianosi, soffocamento
    - Convulsioni, perdita di coscienza, ipotonia grave improvvisa
    - Trauma cranico, ingestione di sostanze tossiche
    - Petecchie o emorragie cutanee improvvise
    - Fontanella anteriore bombata, rigidità nucale
    Per sintomi preoccupanti ma non emergenziali, consiglia sempre di consultare il pediatra.
  PROMPT

  # Default model to use - Single source of truth for model name
  DEFAULT_MODEL = "gpt-5.4-mini"

  # Display name for the model (used in UI)
  MODEL_DISPLAY_NAME = "GPT-5.4 Mini"

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
    accumulated_text = String.new
    citations = []
    file_search_results = []
    response_id = nil
    input_tokens = 0
    output_tokens = 0

    begin
      client = ShubyOpenaiClient.new(@shuby_chat)
      client.stream(message, system_prompt: build_system_prompt) do |event_data|
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
    def create_for_user(user, model: DEFAULT_MODEL, child: nil)
      child ||= user.personal_account&.children&.active&.ordered&.first
      chat = user.shuby_chats.create!(model: model, account: user.personal_account, child: child)
      new(chat)
    end
  end

  private

  # Builds the full system prompt with child context appended
  #
  # @return [String] The complete system prompt
  def build_system_prompt
    prompt = BASE_SYSTEM_PROMPT.dup
    prompt << "\n#{DISPATCHER_INSTRUCTIONS}"
    prompt << "\n#{specialist_prompt}"
    context = child_context_prompt
    prompt << "\n#{context}" if context.present?
    catalog = article_catalog_prompt
    prompt << "\n#{catalog}" if catalog.present?
    prompt
  end

  # Generates the child context section for the system prompt
  #
  # @return [String, nil] The child context block, or nil if no child found
  def child_context_prompt
    child = @shuby_chat.child
    # Fallback for legacy chats without child_id
    child ||= @shuby_chat.account&.children&.active&.ordered&.first
    return nil unless child

    account = @shuby_chat.account
    user = @shuby_chat.user
    family_profile = account&.family_profile
    account_user = account&.account_users&.find_by(user: user)

    lines = ["CONTESTO BAMBINO:"]
    lines << "- Nome: #{child.display_name}"
    lines << "- Età: #{child.detailed_age_display}"

    if child.premature?
      lines << "- Nato prematuro (#{child.gestational_weeks} settimane)"
      lines << "- Età corretta: #{child.corrected_age_in_months} mesi" if child.using_corrected_age?
    end

    lines << "- Sesso: #{I18n.t("children.sex.#{child.sex}", default: child.sex)}" unless child.unspecified?

    if family_profile&.languages_spoken_at_home
      lang_count = family_profile.languages_spoken_at_home
      lang_label = case lang_count
      when 1 then "monolingue"
      when 2 then "bilingue"
      when 3 then "trilingue"
      else "quattro o più lingue"
      end
      lines << "- Contesto linguistico: #{lang_label}"
    end

    if account_user&.relationship_to_child && !account_user.relationship_unspecified?
      lines << "- Relazione caregiver: #{I18n.t("account_users.relationship.#{account_user.relationship_to_child}", default: account_user.relationship_to_child)}"
    end

    lines << ""
    lines << "Usa il nome \"#{child.display_name}\" nelle risposte. Adatta i consigli all'età specifica del bambino."
    lines.join("\n")
  end

  # Generates a compact catalog of published in-app articles for the system prompt.
  # The AI uses this to naturally link to relevant articles in its responses.
  #
  # @return [String, nil] The article catalog block, or nil if no published content
  def article_catalog_prompt
    contents = ArchiveContent.published.ordered.to_a
    return nil if contents.empty?

    type_labels = {"article" => "Articoli", "tip" => "Consigli", "activity" => "Attività"}

    lines = []
    lines << "CONTENUTI IN-APP DISPONIBILI:"
    lines << "Quando pertinente alla domanda del genitore, suggerisci contenuti dell'app usando link markdown: [Titolo](/archive/slug)"
    lines << "Inserisci i link in modo naturale nel testo della risposta."
    lines << "Suggerisci massimo 1-3 contenuti per risposta, solo se realmente rilevanti."
    lines << "Usa SOLO i link esatti elencati qui sotto — non inventare slug."
    lines << ""

    contents.group_by(&:content_type).each do |type, items|
      lines << "#{type_labels[type] || type.capitalize}:"
      items.each do |item|
        lines << "- [#{item.title}](/archive/#{item.slug}) | #{item.category} | #{item.age_range_label}"
      end
      lines << ""
    end

    lines.join("\n")
  end

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
