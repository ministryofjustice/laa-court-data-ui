# frozen_string_literal: true

RSpec.describe Cda::LinkMigratedCasesService do
  describe '.call' do
    subject(:result) { described_class.call(**params) }

    let(:params) { {} }

    context 'with default params', :stub_link_migrated_cases do
      it 'returns a hash with pagination envelope' do
        expect(result).to include('total_results' => 3, 'page' => 1, 'per_page' => 10)
      end

      it 'returns results as an array of hashes' do
        expect(result['results']).to all(be_a(Hash))
      end

      it 'returns the correct number of results' do
        expect(result['results'].size).to eq(3)
      end

      it 'exposes case attributes on each result' do
        expect(result['results'].first).to include('case_urn' => '20GD0217101', 'status' => 'pending')
      end
    end

    context 'with a status filter' do
      let(:params) { { status: 'pending' } }

      before do
        stub_request(:get, %r{http.*/api/internal/v2/link_migrated_cases})
          .with(query: hash_including('status' => 'pending'))
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: load_json_stub('cda/internal_v2_link_migrated_cases_response.json')
          )
      end

      it 'passes status as a query param' do
        expect(result).to include('total_results' => 3)
      end
    end

    context 'with pagination params' do
      let(:params) { { page: 2, per_page: 5 } }

      before do
        stub_request(:get, %r{http.*/api/internal/v2/link_migrated_cases})
          .with(query: hash_including('page' => '2', 'per_page' => '5'))
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: load_json_stub('cda/internal_v2_link_migrated_cases_response.json')
          )
      end

      it 'passes page and per_page as query params' do
        expect(result).to include('total_results' => 3)
      end
    end

    context 'with nil status', :stub_link_migrated_cases do
      let(:params) { { status: nil } }

      it 'does not include status in the query string' do
        result
        expect(WebMock).to(have_requested(:get, %r{/link_migrated_cases})
          .with { |req| !req.uri.query.to_s.include?('status') })
      end
    end
  end
end
