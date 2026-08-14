RSpec.describe Cda::LinkMigratedCase, type: :model do
  describe '.find_from_id' do
    subject(:find_entity) { described_class.find_from_id(id) }

    let(:id) { SecureRandom.uuid }

    it "constructs a request" do
      stub = stub_request(:get, %r{/v2/link_migrated_cases/#{id}}).to_return(body: '{}')

      find_entity

      expect(stub).to have_been_requested
    end

    context 'when id contains unsafe characters' do
      let(:id) { "123/456?789=0" }

      it "sanitises it" do
        stub = stub_request(:get,
                            %r{/v2/link_migrated_cases/123%2F456%3F789=0})
               .to_return(body: '{}')

        find_entity

        expect(stub).to have_been_requested
      end
    end
  end
end
