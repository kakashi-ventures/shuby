# frozen_string_literal: true

require "net/http"
require "json"

# HTTP client for OpenAI Responses API with Server-Sent Events streaming
#
# Handles all HTTP communication and SSE parsing, isolating
# network concerns from business logic.
#
# @example Streaming usage
#   client = ShubyOpenaiClient.new(shuby_chat)
#   client.stream("What milestones at 6 months?", system_prompt: prompt) do |event_data|
#     puts event_data["type"] # => "response.output_text.delta"
#   end
#
class ShubyOpenaiClient
  # OpenAI API endpoint for Responses API
  OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"

  # Initialize the client with a ShubyChat record
  #
  # @param shuby_chat [ShubyChat] The chat record (for model + conversation context)
  def initialize(shuby_chat)
    @shuby_chat = shuby_chat
  end

  # Streams a message through the OpenAI Responses API
  #
  # Sends the message with SSE streaming enabled and yields each
  # parsed event as a Hash to the caller.
  #
  # @param message [String] The user's message
  # @param system_prompt [String] The system instructions
  # @yield [Hash] Each parsed SSE event data
  def stream(message, system_prompt:, &)
    uri = URI(OPENAI_RESPONSES_URL)
    request = build_http_request(uri, message, system_prompt)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120

    http.request(request) do |response|
      unless response.code == "200"
        error_body = response.body
        raise "OpenAI API error (#{response.code}): #{error_body}"
      end

      parse_sse_stream(response, &)
    end
  end

  private

  # Parses the SSE stream from an HTTP response
  #
  # @param response [Net::HTTPResponse] The streaming response
  # @yield [Hash] Each parsed SSE event
  def parse_sse_stream(response)
    buffer = ""
    response.read_body do |chunk|
      buffer += chunk

      while (match = buffer.match(/data: (.+?)\n\n/m))
        buffer = match.post_match
        data_str = match[1].strip

        next if data_str == "[DONE]"

        begin
          yield JSON.parse(data_str)
        rescue JSON::ParserError => e
          Rails.logger.warn("Failed to parse SSE data: #{data_str}, error: #{e.message}")
        end
      end
    end
  end

  # Builds the HTTP request for OpenAI Responses API
  #
  # @param uri [URI] The API endpoint
  # @param message [String] The user's message
  # @param system_prompt [String] The system instructions
  # @return [Net::HTTP::Post] The configured HTTP request
  def build_http_request(uri, message, system_prompt)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)}"

    body = {
      model: @shuby_chat.model || ShubyAssistantService::DEFAULT_MODEL,
      input: message,
      instructions: system_prompt,
      stream: true,
      store: true
    }

    # Add file_search tool only if vector store is configured
    vector_store_id = ENV["OPENAI_VECTOR_STORE_ID"] || Rails.application.credentials.dig(:openai, :vector_store_id)
    if vector_store_id.present?
      body[:tools] = [
        {
          type: "file_search",
          vector_store_ids: [vector_store_id]
        }
      ]
      body[:include] = ["file_search_call.results"]
    end

    # Add conversation context if available
    if @shuby_chat.previous_response_id.present?
      body[:previous_response_id] = @shuby_chat.previous_response_id
    end

    request.body = body.to_json
    request
  end
end
