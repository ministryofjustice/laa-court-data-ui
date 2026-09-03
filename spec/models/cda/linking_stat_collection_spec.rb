RSpec.describe Cda::LinkingStatCollection, type: :model do
  describe ".find_from_range" do
    subject(:find_entity) { described_class.find_from_range(from, to) }

    let(:from) { "2024-01-01" }
    let(:to) { "2024-01-31" }

    it "constructs a request" do
      stub = stub_request(:get,
                          %r{/v2/stats/linking\?from=#{from}&to=#{to}}).to_return(body: "{}")

      find_entity

      expect(stub).to have_been_requested
    end
  end
end
