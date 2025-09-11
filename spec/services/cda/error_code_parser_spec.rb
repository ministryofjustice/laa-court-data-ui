require 'rails_helper'

RSpec.describe Cda::ErrorCodeParser do
  subject(:output) { described_class.call(response, context) }

  let(:response) { instance_double(Faraday::Response, body:) }
  let(:context) { nil }

  context "when a string is provided" do
    let(:body) { '{ "error_codes":["internal_server_error"]}' }

    it 'parses appropriately' do
      expect(output).to eq(
        "Court Data Adaptor could not be reached. This may be a temporary error. " \
        "If this problem persists, please contact the IT Helpdesk on 0800 9175148."
      )
    end
  end

  context "when key is not found" do
    let(:context) { "appeal" }
    let(:body) { { "error_codes" => ["unknown error"] } }

    it 'returns nil' do
      expect(output).to be_nil
    end
  end

  context "when context is irrelevant" do
    let(:context) { "appeal" }
    let(:body) { { "error_codes" => ["internal_server_error"] } }

    it 'ignores context' do
      expect(output).to eq(
        "Court Data Adaptor could not be reached. This may be a temporary error. " \
        "If this problem persists, please contact the IT Helpdesk on 0800 9175148."
      )
    end
  end

  context "when context is relevant" do
    let(:context) { "appeal" }
    let(:body) { { "error_codes" => ["maat_reference_contract_failure"] } }

    it 'uses context' do
      expect(output).to eq(
        "The MAAT reference you provided is not available to be associated with this appellant."
      )
    end
  end
end
