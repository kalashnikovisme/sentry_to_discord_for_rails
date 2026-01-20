# frozen_string_literal: true

require_relative "../../../lib/sentry_to_discord_for_rails/converter"
require_relative "../../../lib/sentry_to_discord_for_rails/notifier"

module Webhooks
  class SentryController < ActionController::Base
    # Disable CSRF protection for webhooks
    skip_before_action :verify_authenticity_token, raise: false

    def create
      return head :bad_request if discord_webhook_url.blank?

      payload = JSON.parse(request.raw_post)

      # Use the converter service
      discord_payload = SentryToDiscordForRails::Converter.new(payload).call

      # Use the notifier service
      notifier = SentryToDiscordForRails::Notifier.new(discord_webhook_url)

      return head :bad_gateway unless notifier.call(discord_payload)

      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error("[Sentry Webhook] JSON parse error: #{e.message}")
      head :bad_request
    rescue Faraday::ClientError => e
      Rails.logger.error("[Sentry Webhook] Discord delivery failed: #{e.message}")
      head :bad_gateway
    end

    private

    def discord_webhook_url
      ENV["DISCORD_WEBHOOK_URL"].presence
    end
  end
end
