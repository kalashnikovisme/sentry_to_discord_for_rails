# Sentry to Discord for Rails

A Rails Engine to receive Sentry webhooks and forward them to Discord in a formatted way.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sentry_to_discord_for_rails', git: 'https://github.com/kalashnikovisme/sentry_to_discord_for_rails.git'
```

And then execute:

```bash
bundle install
```

## Configuration

1. Set the Discord Webhook URL in your environment variables:

```bash
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

## Usage

Mount the engine in your Rails application's `config/routes.rb`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount SentryToDiscordForRails::Engine => "/sentry_to_discord"
end
```

Then, configure your Sentry project to send webhooks to:

`https://your-app.com/sentry_to_discord/webhooks/sentry`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
