# frozen_string_literal: true

require "spec_helper"

RSpec.describe SentryToDiscordForRails::Notifier do
  subject(:notifier) { described_class.new(webhook_url) }

  let(:webhook_url) { "https://discord.com/api/webhooks/123/abc" }
  let(:body) { { content: "Test message" } }

  describe "#call" do
    context "when Discord API returns success" do
      before do
        stub_request(:post, webhook_url)
          .with(
            body: body.to_json,
            headers: { "Content-Type" => "application/json" }
          )
          .to_return(status: 204)
      end

      it "returns true" do
        expect(notifier.call(body)).to be true
      end
    end

    context "when Discord API fails" do
      before do
        stub_request(:post, webhook_url)
          .to_return(status: 500)
      end

      it "returns false" do
        expect(notifier.call(body)).to be false
      end
    end
  end
end
