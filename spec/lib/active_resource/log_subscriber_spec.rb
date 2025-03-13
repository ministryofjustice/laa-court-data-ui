class ActiveResourceLogSubscriberTestImplementation < ActiveResource::LogSubscriber
  attr_reader :output

  def request_without_filtered_logging(input)
    @output = input
  end
end

RSpec.describe ActiveResource::LogSubscriber do
  subject(:filtered_log) do
    ActiveResourceLogSubscriberTestImplementation.new.tap { _1.request_with_filtered_logging(event) }.output
  end

  let(:event) { instance_double(ActiveSupport::Notifications::Event, payload: { request_uri: input }) }

  context "when the query string contains a blacklisted attribute" do
    let(:input) { "https://example.com/some/endpoint?dob=private-data" }

    it "filters out private data" do
      expect(filtered_log.payload[:request_uri]).to eq "https://example.com/some/endpoint?dob=FILTERED"
    end
  end

  context "when there is no query string" do
    let(:input) { "https://example.com/some/endpoint" }

    it "leaves the URI untouched" do
      expect(filtered_log.payload[:request_uri]).to eq "https://example.com/some/endpoint"
    end
  end

  context "when the query string has no exact match" do
    let(:input) { "https://example.com/some/endpoint?a_dob=something&dob-2=something-else" }

    it "leaves the URI untouched" do
      expect(filtered_log.payload[:request_uri]).to eq "https://example.com/some/endpoint?a_dob=something&dob-2=something-else"
    end
  end
end
