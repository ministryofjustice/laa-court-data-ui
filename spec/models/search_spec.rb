# frozen_string_literal: true

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it {
    is_expected.to \
      respond_to(:filters, :filter,
                 :term, :term=,
                 :dob, :dob=,
                 :execute, :errors, :valid?)
  }

  describe '.filters' do
    subject(:filters) { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }

    it {
      expect(filters.map(&:id)).to include(:case_reference, :defendant_name, :defendant_reference)
    }
  end

  describe '#filters' do
    subject(:filters) { described_class.new.filters }

    before { allow(described_class).to receive(:filters) }

    it 'calls class method' do
      filters
      expect(described_class).to have_received(:filters)
    end
  end

  describe '#execute' do
    context 'when v2 search flag is false' do
      before do
        allow(Feature).to receive(:enabled?).with('DEFENDANTS_SEARCH').and_return(false)
        allow(query_class).to receive(:new).and_return(query_instance)
        allow(query_instance).to receive(:call)
        search_instance.execute
      end

      context 'when searching by case reference', stub_no_results: true do
        subject(:search_instance) { described_class.new(filter:, term:) }

        let(:filter) { 'case_reference' }
        let(:term) { 'TEST12345' }
        let(:dob) { Date.parse('21-05-1987') }

        let(:query_class) { CourtDataAdaptor::Query::ProsecutionCase }
        let(:query_instance) { instance_double(query_class) }

        it 'sends term to case reference query object' do
          expect(query_class).to have_received(:new).with(term)
        end

        it 'calls case reference query object' do
          expect(query_instance).to have_received(:call)
        end
      end

      context 'when searching by defendant name', stub_no_results: true do
        subject(:search_instance) { described_class.new(filter:, term:, dob:) }

        let(:filter) { 'defendant_name' }
        let(:term) { 'Maxie Turcotte Raynor' }
        let(:dob) { Date.parse('30-06-1973') }

        let(:query_class) { CourtDataAdaptor::Query::Defendant::ByName }
        let(:query_instance) { instance_double(query_class) }

        it 'sends term and dob to defandant query object' do
          expect(query_class).to have_received(:new).with(term, dob:)
        end

        it 'calls defendant query object' do
          expect(query_instance).to have_received(:call)
        end
      end

      context 'when searching by defendant reference', stub_no_results: true do
        subject(:search_instance) { described_class.new(filter:, term:) }

        let(:filter) { 'defendant_reference' }
        let(:term) { 'defendant-ni-number' }

        let(:query_class) { CourtDataAdaptor::Query::Defendant::ByReference }
        let(:query_instance) { instance_double(query_class) }

        it 'sends term to defandant query object' do
          expect(query_class).to have_received(:new).with(term)
        end

        it 'calls defendant query object' do
          expect(query_instance).to have_received(:call)
        end
      end
    end

    context 'when v2 search flag is true' do
      let(:cdapi_search_service) { CdApi::SearchService }

      before do
        allow(Feature).to receive(:enabled?).with('DEFENDANTS_SEARCH').and_return(true)
        allow(cdapi_search_service).to receive(:call).with(any_args).and_return([])
      end

      context 'when filter is defendant_reference' do
        subject(:search_instance) { described_class.new(filter:, term:) }

        let(:filter) { 'defendant_reference' }
        let(:term) { [nino, asn].sample }
        let(:dob) { Date.parse('30-06-1973') }
        let(:nino) { 'GG121222B' }
        let(:asn) { 'OC22ZJATX15T' }

        it 'calls defendant query object' do
          search_instance.execute
          expect(cdapi_search_service).to have_received(:call).with({ filter:, term:, dob: nil })
        end

        it 'returns result' do
          expect(search_instance.execute).to eq []
        end
      end

      context 'when filter is case_reference' do
        subject(:search_instance) { described_class.new(filter:, term:) }

        let(:filter) { 'case_reference' }
        let(:cd_api_defendant) { instance_double(CdApi::Defendant, id: 100) }
        let(:term) { 'TEST12345' }
        let(:dob) { Date.parse('30-06-1973') }

        before do
          allow(Rails.configuration.x.court_data_api_config).to receive(:uri).and_return('http://localhost:8000/v2')
          allow(Rails.configuration.x.v2).to receive(:search).and_return('true')
          allow(cdapi_search_service).to receive(:call).with(any_args).and_return([cd_api_defendant])
        end

        it 'calls defendant query object' do
          search_instance.execute
          expect(cdapi_search_service).to have_received(:call).with({ filter:, term:, dob: nil })
        end

        it 'returns result' do
          expect(search_instance.execute.first).to eq(cd_api_defendant)
        end
      end

      context 'when filter is defendant_name' do
        subject(:search_instance) { described_class.new(filter:, term:, dob:) }

        let(:filter) { 'defendant_name' }
        let(:term) { 'Maxie Turcotte Raynor' }
        let(:dob) { Date.parse('30-06-1973') }

        before do
          allow(Rails.configuration.x.court_data_api_config).to receive(:uri).and_return('http://localhost:8000/v2')
          allow(Rails.configuration.x.v2).to receive(:search).and_return('true')
        end

        it 'calls defendant query object' do
          search_instance.execute
          expect(cdapi_search_service).to have_received(:call).with({ filter:, term:, dob: })
        end

        it 'returns result' do
          expect(search_instance.execute).to eq []
        end
      end

      context 'when exception ActiveResource::BadRequest raised' do
        subject(:search_instance) { described_class.new(filter:, term:, dob:) }

        let(:filter) { 'case_reference' }
        let(:term) { 'TEST12345' }
        let(:dob) { Date.parse('30-06-1973') }
        let(:cdapi_search_service) { CdApi::SearchService }

        before do
          stub_request(:get, %r{/v2/defendants}).to_return(status: 200, body: '',
                                                           headers: { 'Content-Type' => 'application/json' })
          allow(cdapi_search_service).to receive(:call).with(any_args).and_raise(
            ActiveResource::BadRequest, ''
          )
        end

        it 'returns empty array' do
          expect(search_instance.execute).to eq []
        end
      end

      context 'when exception ActiveResource::ServerError raised' do
        subject(:search_instance) { described_class.new(filter:, term:, dob:) }

        let(:filter) { 'case_reference' }
        let(:term) { 'TEST12345' }
        let(:dob) { Date.parse('30-06-1973') }
        let(:cdapi_search_service) { CdApi::SearchService }

        before do
          allow(cdapi_search_service).to receive(:call).with(any_args).and_raise(
            ActiveResource::ServerError, 'Failed.'
          )
          allow(Sentry).to receive(:capture_exception)
        end

        it 'returns empty array' do
          expect(search_instance.execute).to eq []
        end

        it 'send exception to Sentry' do
          search_instance.execute
          expect(Sentry).to have_received(:capture_exception)
        end
      end
    end
  end

  context 'when validating' do
    subject(:search) { described_class.new(filter:, term:, dob:) }

    context 'with case reference search' do
      let(:filter) { 'case_reference' }
      let(:term) { 'TFL12345' }
      let(:dob) { nil }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:filter, 'Filter required') }
      end

      context 'with not included filter' do
        let(:filter) { 'invalid_filter' }

        it { is_expected.to be_invalid }

        it {
          is_expected.to \
            have_activemodel_error_message(:filter, 'Filter "invalid_filter" is not recognized')
        }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:term, 'Search term required') }
      end

      context 'with blank dob' do
        let(:dob) { nil }

        it { is_expected.to be_valid }
      end
    end

    context 'with defendant name search' do
      let(:filter) { 'defendant_name' }
      let(:term) { 'Mickey Mouse' }
      let(:dob) { Date.current }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:filter, 'Filter required') }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:term, 'Search term required') }
      end

      context 'with non-alphanumeric chars as term' do
        let(:term) { '!' }

        it { is_expected.to be_invalid }

        it {
          is_expected
            .to have_activemodel_error_message(:term, 'Search term must contain only letters and numbers')
        }
      end

      context 'with whitespace chars as term' do
        let(:term) { "\s\s\t" }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:term, 'Search term required') }
      end

      context 'with single char as term' do
        let(:term) { 'a' }

        it { is_expected.to be_invalid }

        it {
          is_expected
            .to have_activemodel_error_message(:term, 'Search term must be at least 2 characters')
        }
      end

      context 'with single char and whitespace as term' do
        let(:term) { "a\s\s\t" }

        it { is_expected.to be_invalid }

        it {
          is_expected
            .to have_activemodel_error_message(:term, 'Search term must be at least 2 characters')
        }
      end

      context 'with 2 chars as term' do
        let(:term) { 'at' }

        it { is_expected.to be_valid }
      end

      context 'with apostrophe in term' do
        let(:term) { "o'conner" }

        it { is_expected.to be_valid }
      end

      context 'with hyphen in term' do
        let(:term) { 'anne-marie' }

        it { is_expected.to be_invalid }

        it {
          is_expected
            .to have_activemodel_error_message(:term, 'Search term must contain only letters and numbers')
        }
      end

      context 'with blank dob' do
        let(:dob) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:dob, 'Defendant date of birth required') }
      end
    end

    context 'with defendant reference search' do
      let(:filter) { 'defendant_reference' }
      let(:term) { 'HR669639M' }
      let(:dob) { nil }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:filter, 'Filter required') }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activemodel_error_message(:term, 'Search term required') }
      end
    end
  end
end
