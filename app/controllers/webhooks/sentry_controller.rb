# frozen_string_literal: true

require_relative "../../../lib/sentry_to_discord_for_rails/converter"
require_relative "../../../lib/sentry_to_discord_for_rails/notifier"

module Webhooks
  # Webhook controller to receive Sentry events
  class SentryController < ActionController::Base
    # Disable CSRF protection for webhooks
    skip_before_action :verify_authenticity_token, raise: false

    def create
      return head :bad_request if discord_webhook_url.blank?

      process_payload
    rescue JSON::ParserError => e
      log_error("JSON parse error: #{e.message}")
      head :bad_request
    rescue Faraday::ClientError => e
      log_error("Discord delivery failed: #{e.message}")
      head :bad_gateway
    end

    private

    def discord_webhook_url
      ENV["DISCORD_WEBHOOK_URL"].presence
    end

    def process_payload
      payload = JSON.parse(request.raw_post)
      discord_payload = SentryToDiscordForRails::Converter.new(payload).call
      notifier = SentryToDiscordForRails::Notifier.new(discord_webhook_url)

      return head :bad_gateway unless notifier.call(discord_payload)

      head :ok
    end

    def log_error(msg)
      Rails.logger.error("[Sentry Webhook] #{msg}")
    end
  end
end
