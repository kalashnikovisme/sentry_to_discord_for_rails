# frozen_string_literal: true

require "rails"
require "faraday"
require_relative "sentry_to_discord_for_rails/version"
require_relative "sentry_to_discord_for_rails/converter"
require_relative "sentry_to_discord_for_rails/notifier"

module SentryToDiscordForRails
  class Engine < ::Rails::Engine
  end
end
