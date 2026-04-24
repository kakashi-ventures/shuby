# frozen_string_literal: true

# RubyLLM configuration for Shuby chat assistant
RubyLLM.configure do |config|
  # OpenAI API key from environment variable
  config.openai_api_key = Rails.application.credentials.dig(:openai, :api_key)

  # Default model for chat
  config.default_model = "gpt-5.4-mini"

  # Request timeout in seconds
  config.request_timeout = 120

  # Enable logging in development
  config.log_level = Rails.env.development? ? :debug : :info
end

# Autoload tools from app/tools directory
Rails.autoloaders.main.push_dir(Rails.root.join("app/tools"))
