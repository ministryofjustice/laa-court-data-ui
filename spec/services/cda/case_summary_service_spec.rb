# frozen_string_literal: true

RSpec.describe Cda::CaseSummaryService do
  describe '#call' do
    context 'when filter is case_reference' do
      subject(:case_service) { described_class.call(case_reference) }

      let(:case_reference) { 'TEST12345' }

      context 'when successful response', :stub_case_search do
        it 'returns response with prosecution case reference' do
          expect(case_service.prosecution_case_reference).to be_a(String)
        end

        it 'returns response with hearing summaries' do
          expect(case_service.hearing_summaries.size).to eq 2
        end

        it 'returns response with overall defendants' do
          expect(case_service.defendant_summaries.size).to eq 4
        end

        it 'returns response mapped to Cda::ProsecutionCase' do
          expect(case_service).to be_instance_of(Cda::ProsecutionCase)
        end
      end

      context 'when multiple results' do
        before do
          stub_request(
            :post, %r{http.*/v2/prosecution_cases}
          ).to_return(status: 200,
                      headers: { 'Content-Type' => 'application/json' },
                      body: load_json_stub('cda/double_case_response.json'))
        end

        it 'returns the one with the right URN' do
          expect(case_service.prosecution_case_reference).to eq case_reference
        end
      end
    end
  end
end
