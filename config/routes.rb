# frozen_string_literal: true

SentryToDiscordForRails::Engine.routes.draw do
  post "webhooks/sentry", to: "webhooks/sentry#create"
end
