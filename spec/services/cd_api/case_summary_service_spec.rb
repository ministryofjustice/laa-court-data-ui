# frozen_string_literal: true

RSpec.describe CdApi::CaseSummaryService do
  describe '#call' do
    context 'when filter is case_reference' do
      subject(:case_service) { described_class.call(params:) }

      let(:case_reference) { 'TEST12345' }
      let(:params) { { urn: case_reference } }

      context 'when successful response', :stub_v2_hearing_summary, :vcr do
        it 'returns response with prosecution case reference' do
          expect(case_service.prosecution_case_reference).to be_a(String)
        end

        it 'returns response with hearing summaries' do
          expect(case_service.hearing_summaries.size).to eq 3
        end

        it 'returns response with overall defendants' do
          expect(case_service.overall_defendants.size).to eq 4
        end

        it 'returns response mapped to CdApi::CaseSummary' do
          expect(case_service).to be_instance_of(CdApi::CaseSummary)
        end
      end
    end
  end
end
