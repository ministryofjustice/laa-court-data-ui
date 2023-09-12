# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Hearing do
  subject { described_class }

  def self.resource
    CourtDataAdaptor::Resource::Hearing
  end

  it_behaves_like('court_data_adaptor acts_as_resource object', resource:) do
    let(:klass) { described_class }
    let(:instance) { described_class.new(nil) }
  end

  it_behaves_like 'court_data_adaptor query object'

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term) }
    let(:term) { 'a-hearing-uuid' }
    let(:resource) { self.class.resource }
    let(:resultset) { instance_double('ResultSet') }

    before do
      allow(instance).to receive(:refresh_token_if_required!)
      allow(resource).to receive(:includes).and_return(resultset)
      allow(resultset).to receive(:find).and_return(resultset)
      allow(resultset).to receive(:first)
      call
    end

    it 'refreshes access_token if required' do
      expect(instance).to have_received(:refresh_token_if_required!)
    end

    it 'sends inclusion request to resource' do
      expect(resource).to have_received(:includes)
        .with(:hearing_events, :providers, :cracked_ineffective_trial)
    end

    it 'sends find query to resource' do
      expect(resultset)
        .to have_received(:find)
        .with(term)
    end

    it 'sends first message to resultset' do
      expect(resultset).to have_received(:first)
    end
  end

  context 'with results', :stub_hearing do
    subject(:result) { described_class.new(term).call }

    let(:term) { 'a-hearing-uuid' }

    it 'returns a hearing resource' do
      expect(result).to be_instance_of(CourtDataAdaptor::Resource::Hearing)
    end

    it 'returns resource that responds to hearing_events' do
      expect(result).to respond_to :hearing_events
    end

    it 'returns resource that responds to providers' do
      expect(result).to respond_to :providers
    end
  end
end
