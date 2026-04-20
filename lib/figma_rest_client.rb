# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# Minimal client for the Figma REST API.
#
# Used by `bin/figma_prototype_info` to pull prototype interactions and
# transition timings that the Figma MCP server does not expose.
#
# Auth: personal access token from Rails credentials (`figma.personal_access_token`)
# with fallback to ENV["FIGMA_PERSONAL_ACCESS_TOKEN"]. Create one at
# figma.com/developers/api#access-tokens with scope `files:read`.
class FigmaRestClient
  class Error < StandardError; end
  class AuthError < Error; end

  class RateLimited < Error
    attr_reader :retry_after
    def initialize(message, retry_after:)
      super(message)
      @retry_after = retry_after
    end
  end

  API_HOST = "api.figma.com"

  # GET /v1/files/:file_key/nodes?ids=...&depth=N
  #
  # @param file_key [String] Figma file key (from URL)
  # @param node_ids [Array<String>] node IDs, e.g. ["2002:8929", "375:5429"]
  # @param depth [Integer] tree depth to fetch under each node
  # @return [Hash] parsed JSON response
  def self.fetch_nodes(file_key:, node_ids:, depth: 8)
    new.fetch_nodes(file_key: file_key, node_ids: node_ids, depth: depth)
  end

  def fetch_nodes(file_key:, node_ids:, depth: 8)
    uri = URI("https://#{API_HOST}/v1/files/#{file_key}/nodes")
    uri.query = URI.encode_www_form(ids: node_ids.join(","), depth: depth)

    response = get(uri)
    check_rate_limit_warning(response)
    handle_errors(response)

    JSON.parse(response.body)
  end

  private

  def get(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 30) do |http|
      req = Net::HTTP::Get.new(uri)
      req["X-Figma-Token"] = token
      http.request(req)
    end
  end

  def token
    @token ||= begin
      from_credentials = defined?(Rails) && Rails.application.credentials.dig(:figma, :personal_access_token)
      from_credentials || ENV["FIGMA_PERSONAL_ACCESS_TOKEN"] || raise(AuthError, missing_token_message)
    end
  end

  def check_rate_limit_warning(response)
    return unless response["X-Figma-Rate-Limit-Type"] == "low"

    warn "[FigmaRestClient] warning: rate-limit tier is 'low' — next calls may 429. " \
      "Consider upgrading the Figma plan or reducing call frequency."
  end

  def handle_errors(response)
    case response.code.to_i
    when 200 then nil
    when 401, 403
      raise AuthError, "Figma API auth failed (#{response.code}). " \
        "Check the token scope includes `files:read`."
    when 429
      raise RateLimited.new("Figma API rate limit hit",
        retry_after: response["Retry-After"])
    else
      raise Error, "Figma API error #{response.code}: #{response.body.to_s[0, 200]}"
    end
  end

  def missing_token_message
    <<~MSG
      Figma personal access token not configured.
      1. Create one at https://www.figma.com/developers/api#access-tokens (scope: files:read)
      2. Add it with: bin/rails credentials:edit
           figma:
             personal_access_token: figd_...
         Or set ENV["FIGMA_PERSONAL_ACCESS_TOKEN"].
    MSG
  end
end
