# frozen_string_literal: true

require "spec_helper"

RSpec.describe SentryToDiscordForRails::Converter do
  subject(:converter) { described_class.new(payload) }

  let(:payload) do
    {
      "project" => "test-project",
      "event" => {
        "title" => "Test Error",
        "culprit" => "SomeController#index",
        "environment" => "production",
        "level" => "error",
        "release" => "abc1234",
        "event_id" => "evt123",
        "timestamp" => 1_674_234_567.0,
        "message" => { "formatted" => "Something went wrong" },
        "web_url" => "https://sentry.io/test-project/events/evt123/"
      }
    }
  end

  describe "#call" do
    it "returns a valid Discord payload" do
      result = converter.call

      expect(result[:content]).to include("**test-project**")
      expect(result[:content]).to include("Test Error")

      embed = result[:embeds].first
      expect(embed[:title]).to eq("Test Error")
      expect(embed[:url]).to eq("https://sentry.io/test-project/events/evt123/")
      expect(embed[:color]).to eq(0xFF0000)

      fields = embed[:fields]
      expect(fields).to include(include(name: "Project", value: "test-project"))
      expect(fields).to include(include(name: "Environment", value: "production"))
    end
  end
end
