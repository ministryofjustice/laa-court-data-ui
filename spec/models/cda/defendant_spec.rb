RSpec.describe Cda::Defendant, type: :model do
  describe '.find_from_id_and_urn' do
    subject(:find_entity) { described_class.find_from_id_and_urn(id, urn) }

    let(:id) { SecureRandom.uuid }
    let(:urn) { 'ABC123456' }

    it "constructs a request" do
      stub = stub_request(:get, %r{/v2/prosecution_cases/#{urn}/defendants/#{id}}).to_return(body: '{}')

      find_entity

      expect(stub).to have_been_requested
    end

    context 'when params contain unsafe characters' do
      let(:id) { "123/456?789=0" }
      let(:urn) { 'ABC123456 ' }

      it "sanitises them" do
        stub = stub_request(:get,
                            %r{/v2/prosecution_cases/ABC123456%20/defendants/123%2F456%3F789=0})
               .to_return(body: '{}')

        find_entity

        expect(stub).to have_been_requested
      end
    end
  end
end
