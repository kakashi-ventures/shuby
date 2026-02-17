# frozen_string_literal: true

# Processes and persists citation data from OpenAI file search results
#
# Extracts citation information from SSE events (file search results
# and annotations) and saves them as tool calls on the assistant message.
#
# @example Processing events during streaming
#   citations = []
#   file_search_results = []
#
#   ShubyCitationProcessor.process_file_search_results(event_data, citations, file_search_results)
#   ShubyCitationProcessor.process_annotation(event_data, citations)
#
#   ShubyCitationProcessor.save_citations(assistant_message, citations, file_search_results, query)
#
class ShubyCitationProcessor
  # Regex pattern to match OpenAI citation markers like 【filecite...】, 【turn0file1】, etc.
  CITATION_MARKER_PATTERN = /【[^】]*】/

  class << self
    # Extracts citations and snippets from a file_search_call.results event
    #
    # @param event_data [Hash] The parsed SSE event data
    # @param citations [Array<Hash>] Accumulator for citation entries
    # @param file_search_results [Array<Hash>] Accumulator for search result snippets
    def process_file_search_results(event_data, citations, file_search_results)
      results = event_data["results"] || []
      results.each do |result|
        file_name = result["file_name"] || result["filename"] || "Documento"
        text = result["text"]

        unless citations.any? { |c| c[:file_name] == file_name }
          citations << {file_name: file_name}
        end
        if text.present?
          file_search_results << {file_name: file_name, text: text.truncate(500)}
        end
      end
    end

    # Extracts citation info from an annotation.added event
    #
    # @param event_data [Hash] The parsed SSE event data
    # @param citations [Array<Hash>] Accumulator for citation entries
    def process_annotation(event_data, citations)
      annotation = event_data["annotation"] || {}
      file_name = annotation["filename"]
      if file_name.present? && !citations.any? { |c| c[:file_name] == file_name }
        citations << {file_name: file_name}
      end
    end

    # Persists collected citations as a tool call on the assistant message
    #
    # @param assistant_message [ShubyMessage] The saved assistant message
    # @param citations [Array<Hash>] The collected citation entries
    # @param file_search_results [Array<Hash>] The collected search result snippets
    # @param query [String] The original user query
    def save_citations(assistant_message, citations, file_search_results, query)
      return unless citations.any?

      tool_call = assistant_message.tool_calls.new(
        tool_call_id: "file_search_#{SecureRandom.hex(8)}",
        name: "file_search",
        arguments: {query: query}
      )
      # Use write_attribute to store in the result JSON column directly
      # (bypassing the has_one :result association from acts_as_tool_call)
      tool_call.write_attribute(:result, {citations: citations, snippets: file_search_results})
      tool_call.save!
    end

    # Strips OpenAI citation markers from text content
    #
    # These markers like 【filecite...】, 【turn0file1】 are inserted by the API
    # but should not be displayed to users.
    #
    # @param text [String] The text to clean
    # @return [String] Text with citation markers removed
    def strip_citation_markers(text)
      return text if text.blank?

      text.gsub(CITATION_MARKER_PATTERN, "")
    end
  end
end
