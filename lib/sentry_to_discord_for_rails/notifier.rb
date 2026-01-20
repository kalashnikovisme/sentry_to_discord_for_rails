# frozen_string_literal: true

require "faraday"

module SentryToDiscordForRails
  class Notifier
    def initialize(discord_webhook_url)
      @discord_webhook_url = discord_webhook_url
    end

    def call(body)
      response = Faraday.post(@discord_webhook_url) do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = body.to_json
      end

      return true if response.success?

      # We can't use Rails.logger here easily if it's not available, but since this is an engine, it probably is.
      # However, to be safe and clean, we might just return false or raise an error.
      # The original code logged an error.
      if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        Rails.logger.error("[Sentry Webhook] Discord responded with status #{response.status}")
      end

      false
    end
  end
end
