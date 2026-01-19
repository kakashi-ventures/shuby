# frozen_string_literal: true

# RubyLLM tool for searching the OpenAI Vector Store
# Contains scientific knowledge base for child development (0-36 months)
#
# @example Usage in chat
#   chat.with_tool(FileSearchTool).ask("What are the milestones at 6 months?")
#
class FileSearchTool < RubyLLM::Tool
  description "Search the scientific knowledge base for child development information (0-36 months). " \
              "Use this tool to find evidence-based information about infant development, milestones, " \
              "sleep, nutrition, motor skills, language development, and parenting tips."

  param :query, type: :string, desc: "Search query for finding relevant documents about child development"

  OPENAI_API_URL = "https://api.openai.com/v1"

  # Executes the vector store search
  #
  # @param query [String] The search query
  # @return [Hash] Search results with citations and snippets
  def execute(query:)
    return {error: I18n.t("file_search_tool.query_blank")} if query.blank?

    store_id = vector_store_id
    return {error: I18n.t("file_search_tool.vector_store_not_configured")} unless store_id

    api_key = openai_api_key
    return {error: I18n.t("file_search_tool.api_key_not_configured")} unless api_key

    # Search the vector store using direct HTTP call
    # (ruby-openai gem doesn't have this endpoint yet)
    response = search_vector_store(store_id, query, api_key)

    results = response["data"] || []

    if results.empty?
      return {
        answer: I18n.t("file_search_tool.no_results"),
        citations: [],
        snippets: []
      }
    end

    # Format results for the LLM
    citations = []
    snippets = []
    seen_files = Set.new

    results.each do |result|
      filename = result.dig("file_name") || result.dig("filename") || I18n.t("file_search_tool.document")
      file_id = result.dig("file_id")
      content = extract_content(result)
      score = result.dig("score") || 0

      # Collect unique citations
      unless seen_files.include?(filename)
        citations << {
          file_name: filename,
          file_id: file_id
        }
        seen_files << filename
      end

      # Collect snippets
      snippets << {
        file_name: filename,
        content: content.truncate(500),
        score: score
      }
    end

    # Build context for the LLM
    context = snippets.map do |s|
      "**#{I18n.t("file_search_tool.source", file_name: s[:file_name])}**\n#{s[:content]}"
    end.join("\n\n---\n\n")

    {
      context: context,
      citations: citations,
      snippets: snippets,
      query: query
    }
  rescue Faraday::Error => e
    Rails.logger.error("FileSearchTool error: #{e.message}")
    {error: I18n.t("file_search_tool.search_error", message: e.message)}
  end

  private

  # Extracts content from various response formats
  #
  # @param result [Hash] The search result
  # @return [String] The extracted content
  def extract_content(result)
    # Try different content locations
    result.dig("content", 0, "text") ||
      result.dig("content") ||
      result.dig("text") ||
      ""
  end

  # Gets the OpenAI API key from credentials or environment
  #
  # @return [String] The API key
  def openai_api_key
    Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
  end

  # Gets the Vector Store ID from credentials or environment
  #
  # @return [String] The Vector Store ID
  def vector_store_id
    Rails.application.credentials.dig(:openai, :vector_store_id) || ENV["OPENAI_VECTOR_STORE_ID"]
  end

  # Searches the vector store using OpenAI API
  #
  # @param store_id [String] The vector store ID
  # @param query [String] The search query
  # @param api_key [String] The OpenAI API key
  # @return [Hash] The search response
  def search_vector_store(store_id, query, api_key)
    connection = Faraday.new(url: OPENAI_API_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    response = connection.post("vector_stores/#{store_id}/search") do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Content-Type"] = "application/json"
      req.headers["OpenAI-Beta"] = "assistants=v2"
      req.body = {
        query: query,
        max_num_results: 5,
        rewrite_query: true
      }
    end

    unless response.success?
      error_message = response.body.dig("error", "message") || "Unknown error"
      raise Faraday::Error, "Vector store search failed: #{error_message}"
    end

    response.body
  end
end
