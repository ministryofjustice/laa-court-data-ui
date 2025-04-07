# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Defendant::ByUuid do
  subject { described_class }

  let(:instance) { described_class.new(nil) }
  let(:term) { 'b3221b46-b98c-47b7-a285-be681d2cac4e' }

  def self.resource
    CourtDataAdaptor::Resource::Defendant
  end

  it_behaves_like('court_data_adaptor acts_as_resource object', resource:) do
    let(:klass) { described_class }
    let(:instance) { described_class.new(nil) }
  end

  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term) }
    let(:resource) { self.class.resource }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:includes).and_return(resultset)
      allow(resultset).to receive(:includes).with('offences').and_return(resultset)
      allow(resultset).to receive(:where).with(full_hearing_data: false).and_return(resultset)
      allow(resultset).to receive_messages(find: resultset, first: resultset, each_with_object: Array)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends includes(:offences) query to resource' do
      expect(resource).to have_received(:includes).with('offences')
    end

    it 'sends .find message to resultset' do
      expect(resultset).to have_received(:find)
    end
  end

  context 'with results', :vcr do
    subject(:results) { described_class.new(term).call }

    let(:term) { 'b3221b46-b98c-47b7-a285-be681d2cac4e' }

    it 'returns defendant resources' do
      expect(results).to be_instance_of(CourtDataAdaptor::Resource::Defendant)
    end

    it 'returns only defendants with matching uuid' do
      expect(results).to have_attributes(id: term)
    end

    it 'includes offences' do
      expect(results).to respond_to(:offences)
    end
  end
end
