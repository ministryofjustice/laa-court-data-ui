require "rails_helper"

RSpec.describe Cda::ErrorCodeParser do
  subject(:output) { described_class.call(response) }

  let(:response) { instance_double(Faraday::Response, body:) }

  context "when a string is provided" do
    let(:body) { '{ "error_codes":["internal_server_error"]}' }

    it "parses appropriately" do
      expect(output).to eq(
        "Court Data Adaptor could not be reached. This may be a temporary error. " \
        "If this problem persists, please contact the IT Helpdesk on 0800 9175148.",
      )
    end
  end

  context "when key is not found" do
    let(:context) { "appeal" }
    let(:body) { { "error_codes" => ["unknown error"] } }

    it "returns nil" do
      expect(output).to be_nil
    end
  end

  context "when a hash is provided" do
    let(:context) { "appeal" }
    let(:body) { { "error_codes" => %w[internal_server_error] } }

    it "ignores context" do
      expect(output).to eq(
        "Court Data Adaptor could not be reached. This may be a temporary error. " \
        "If this problem persists, please contact the IT Helpdesk on 0800 9175148.",
      )
    end
  end
end
