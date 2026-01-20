# frozen_string_literal: true

require "json"

module SentryToDiscordForRails
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

    def sentry_attributes
      event = payload["event"] || {}

      {
        event: event,
        project: (if payload["project"].is_a?(Hash)
                    payload.dig("project",
                                "slug")
                  else
                    nil
                  end) || payload["project"] || "Sentry",
        title: event["title"] || event.dig("metadata", "title") || payload["title"] || "Sentry notification",
        culprit: event["culprit"] || event.dig("metadata", "value"),
        url: event["web_url"] || payload["web_url"] || payload["url"],
        environment: event["environment"] || payload["environment"],
        level: event["level"] || payload["level"],
        release: event["release"] || payload["release"],
        event_id: event["event_id"] || payload["event_id"],
        timestamp: event["timestamp"] || payload["timestamp"],
        message: event.dig("message", "formatted")
      }
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
      description_parts = []
      description_parts << details[:message] if details[:message].present?
      description_parts << "Location: #{details[:culprit]}" if details[:culprit].present?

      fields = []
      fields << { name: "Project", value: details[:project], inline: true } if details[:project].present?
      fields << { name: "Environment", value: details[:environment], inline: true } if details[:environment].present?
      fields << { name: "Level", value: details[:level], inline: true } if details[:level].present?
      fields << { name: "Release", value: details[:release], inline: true } if details[:release].present?
      fields << { name: "Event ID", value: details[:event_id], inline: true } if details[:event_id].present?

      {
        title: details[:title],
        url: details[:url],
        description: description_parts.join("\n").presence,
        color: 0xFF0000,
        fields: fields,
        timestamp: details[:timestamp]
      }.compact
    end
  end
end
