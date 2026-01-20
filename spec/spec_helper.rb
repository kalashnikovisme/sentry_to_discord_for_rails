# frozen_string_literal: true

require "sentry_to_discord_for_rails"

require "sentry_to_discord_for_rails"
require "webmock/rspec"
require "action_controller/railtie"
require "rspec/rails"

module Dummy
  class Application < Rails::Application
    config.eager_load = false
    config.secret_key_base = "test"
    config.hosts << "www.example.com"
  end
end
Dummy::Application.initialize!

Dummy::Application.routes.draw do
  mount SentryToDiscordForRails::Engine => "/sentry_to_discord"
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
