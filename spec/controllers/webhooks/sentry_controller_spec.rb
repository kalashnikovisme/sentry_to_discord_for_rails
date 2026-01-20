# frozen_string_literal: true

require "spec_helper"
require_relative "../../../app/controllers/webhooks/sentry_controller"

# Since we don't have a full dummy app, we mock the controller behavior or assume it loads correct if we had one.
# However, testing controllers without a dummy app in engines is tricky.
# We will write a spec that assumes standard RSpec controller testing is available.
# If this fails, we might need to rely on the service tests which cover 90% of the logic.

# NOTE: This test might require a dummy app to run properly.
RSpec.describe Webhooks::SentryController, type: :controller do
  describe "POST #create" do
    routes { SentryToDiscordForRails::Engine.routes }
    let(:params) { { project: "test", event: {} } }
    let(:webhook_url) { "https://discord.com/webhook" }

    before do
      allow(ENV).to receive(:[]).with("DISCORD_WEBHOOK_URL").and_return(webhook_url)
    end

    context "when webhook url is missing" do
      let(:webhook_url) { nil }

      it "returns bad request" do
        post :create, body: params.to_json, as: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when webhook url is present" do
      let(:converter) { instance_double(SentryToDiscordForRails::Converter) }
      let(:notifier) { instance_double(SentryToDiscordForRails::Notifier) }

      before do
        allow(SentryToDiscordForRails::Converter).to receive(:new).and_return(converter)
        allow(SentryToDiscordForRails::Notifier).to receive(:new).and_return(notifier)
        allow(converter).to receive(:call).and_return({})
      end

      it "returns ok when notifier succeeds" do
        allow(notifier).to receive(:call).and_return(true)
        post :create, body: params.to_json, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns bad gateway when notifier fails" do
        allow(notifier).to receive(:call).and_return(false)
        post :create, body: params.to_json, as: :json
        expect(response).to have_http_status(:bad_gateway)
      end
    end
  end
end
