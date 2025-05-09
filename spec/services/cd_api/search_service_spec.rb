# frozen_string_literal: true

RSpec.describe CdApi::SearchService do
  describe '#call' do
    context 'when filter is case_reference' do
      subject(:search) { described_class.call(filter:, term:, dob:) }

      let(:filter) { 'case_reference' }
      let(:term) { 'TEST12345' }
      let(:dob) { nil }

      context 'with dirty term' do
        let(:term) { 'a /case-URN' }
        let(:cda_searcher) { CourtDataAdaptor::DefendantSearchService }

        before do
          allow(cda_searcher).to receive(:call).with(any_args)
          search
        end

        it 'strips whitespace and some symbols' do
          expect(cda_searcher).to have_received(:call).with('ACASEURN')
        end
      end

      context 'when successful response', :stub_defendants_case_search do
        it 'response with array of defendants' do
          expect(search.size).to eq 4
        end

        it 'returns response mapped to Cda::Defendant' do
          expect(search.first).to be_instance_of(Cda::Defendant)
        end

        it 'returns response that response to prosecution_case_reference' do
          expect(search.first).to respond_to :prosecution_case_reference
        end

        it 'returns response that response to id' do
          expect(search.first).to respond_to :id
        end
      end

      context 'when unsuccessful response' do
        before do
          stub_request(:get, %r{http.*/v2/prosecution_cases\?filter.*}).to_return(
            status: 400, body: '',
            headers: { 'Content-Type' => 'application/json' }
          )
        end

        it 'raises ActiveResource::BadRequest exception' do
          expect { search }.to raise_error(ActiveResource::BadRequest)
        end
      end
    end

    context 'when filter is defendant_name', :stub_defendants_name_search do
      subject(:search) { described_class.call(filter:, term:, dob:) }

      let(:filter) { 'defendant_name' }
      let(:term) { 'Maxie Turcotte Raynor' }
      let(:dob) { Date.parse('30-06-1973') }

      it 'response with array of defendants' do
        expect(search.size).to eq 4
      end

      it 'returns response mapped to CdApi::Defendant' do
        expect(search.first).to be_instance_of(CdApi::Defendant)
      end

      it 'returns respons that responds to prosecution_case_reference' do
        expect(search.first).to respond_to :prosecution_case_reference
      end

      it 'returns response that responds to id' do
        expect(search.first).to respond_to :id
      end

      context 'when unsuccessful response', :stub_defendants_failed_search do
        before do
          stub_request(:get, %r{/v2/defendants}).to_return(status: 400, body: '',
                                                           headers: { 'Content-Type' => 'application/json' })
        end

        it 'raises ActiveResource::BadRequest exception' do
          expect { search }.to raise_error(ActiveResource::BadRequest)
        end
      end
    end

    context 'when filter is defendant_reference', :stub_defendants_ref_search do
      subject(:search) { described_class.call(filter:, term:, dob:) }

      let(:filter) { 'defendant_reference' }
      let(:nino) { 'GG121222B' }
      let(:term) { nino }
      let(:dob) { nil }
      let(:reference_parser_result) { Struct.new(:kind, :value) }

      it 'response with array of defendants' do
        expect(search.size).to eq 4
      end

      it 'returns response mapped to CdApi::Defendant' do
        expect(search.first).to be_instance_of(CdApi::Defendant)
      end

      it 'returns response that responds to prosecution_case_reference' do
        expect(search.first).to respond_to :prosecution_case_reference
      end

      it 'returns response that responds to id' do
        expect(search.first).to respond_to :id
      end

      it 'calls ReferenceParserService' do
        allow(CdApi::ReferenceParserService).to receive(:new)
          .with(any_args).and_return(reference_parser_result.new(:nino, term))
        search
        expect(CdApi::ReferenceParserService).to have_received(:new).with(term)
      end

      context 'when term is asn' do
        let(:asn) { 'OC22ZJATX15T' }
        let(:term) { asn }

        it 'response with array of defendants' do
          expect(search.size).to eq 4
        end

        it 'returns response mapped to CdApi::Defendant' do
          expect(search.first).to be_instance_of(CdApi::Defendant)
        end

        it 'returns response that responds to prosecution_case_reference' do
          expect(search.first).to respond_to :prosecution_case_reference
        end

        it 'returns response that responds to id' do
          expect(search.first).to respond_to :id
        end

        it 'calls ReferenceParserService' do
          allow(CdApi::ReferenceParserService).to receive(:new)
            .with(any_args).and_return(reference_parser_result.new(:asn, term))
          search
          expect(CdApi::ReferenceParserService).to have_received(:new).with(term)
        end
      end

      context 'when unsuccessful response', :stub_defendants_failed_search do
        it 'raises ActiveResource::BadRequest exception' do
          expect { search }.to raise_error(ActiveResource::BadRequest)
        end
      end
    end
  end
end
