# frozen_string_literal: true

require "json"

module SentryToDiscordForRails
  # Converts Sentry payload to Discord webhook payload
  class Converter
    def initialize(payload)
      @payload = payload
    end

    def call
      details = sentry_attributes
      {
        content: build_fallback_message(details),
        embeds: [build_embed(details)]
      }
    end

    private

    attr_reader :payload

    # rubocop:disable Metrics/MethodLength
    def sentry_attributes
      {
        event: event,
        project: project_slug,
        title: title,
        culprit: culprit,
        url: url,
        environment: environment,
        level: level,
        release: release,
        event_id: event_id,
        timestamp: timestamp,
        message: message_formatted
      }
    end
    # rubocop:enable Metrics/MethodLength

    def event
      @event ||= payload["event"] || {}
    end

    def project_slug
      (payload["project"].is_a?(Hash) ? payload.dig("project", "slug") : nil) || payload["project"] || "Sentry"
    end

    def title
      event["title"] || event.dig("metadata", "title") || payload["title"] || "Sentry notification"
    end

    def culprit
      event["culprit"] || event.dig("metadata", "value")
    end

    def url
      event["web_url"] || payload["web_url"] || payload["url"]
    end

    def environment
      event["environment"] || payload["environment"]
    end

    def level
      event["level"] || payload["level"]
    end

    def release
      event["release"] || payload["release"]
    end

    def event_id
      event["event_id"] || payload["event_id"]
    end

    def timestamp
      event["timestamp"] || payload["timestamp"]
    end

    def message_formatted
      event.dig("message", "formatted")
    end

    def build_fallback_message(details)
      [
        "**#{details[:project]}**",
        details[:title],
        ("Location: #{details[:culprit]}" if details[:culprit].present?),
        (details[:url] if details[:url].present?)
      ].compact.join(" - ")
    end

    def build_embed(details)
      {
        title: details[:title],
        url: details[:url],
        description: build_description(details),
        color: 0xFF0000,
        fields: build_fields(details),
        timestamp: details[:timestamp]
      }.compact
    end

    def build_description(details)
      [
        details[:message],
        ("Location: #{details[:culprit]}" if details[:culprit].present?)
      ].compact.join("\n").presence
    end

    def build_fields(details)
      [
        ({ name: "Project", value: details[:project], inline: true } if details[:project].present?),
        ({ name: "Environment", value: details[:environment], inline: true } if details[:environment].present?),
        ({ name: "Level", value: details[:level], inline: true } if details[:level].present?),
        ({ name: "Release", value: details[:release], inline: true } if details[:release].present?),
        ({ name: "Event ID", value: details[:event_id], inline: true } if details[:event_id].present?)
      ].compact
    end
  end
end
