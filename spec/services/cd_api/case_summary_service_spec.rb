# frozen_string_literal: true

RSpec.describe CdApi::CaseSummaryService do
  describe '#call' do
    context 'when filter is case_reference' do
      subject(:case_service) { described_class.call(params:) }

      let(:case_reference) { 'TEST12345' }
      let(:params) { {:urn => case_reference} }

      context 'when successful response', stub_v2_hearing_summary: true, vcr: true do
        it 'returns response with prosecution case reference' do
          expect(case_service.prosecution_case_reference).to be_kind_of(String)
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

      context 'when invalid endpoint call' do
        before do
          stub_request(:get, %r{/v2/hearingsummaries/#{case_reference}}).to_return(status: 400, body: '',
                                                           headers: { 'Content-Type' => 'application/json' })
        end

        it 'rescues ActiveResource::BadRequest exception' do
          allow(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:info).with('CLIENT_ERROR_OCCURRED')

          case_service
        end
      end

      context 'when server error' do
        before do
          stub_request(:get, %r{/v2/hearingsummaries/#{case_reference}}).to_return(status: 500, body: '',
                                                           headers: { 'Content-Type' => 'application/json' })
        end

        it 'rescues ActiveResource::ServerError exception' do
          allow(Rails.logger).to receive(:error)
          expect(Rails.logger).to receive(:error ).with('SERVER_ERROR_OCCURRED')

          case_service
        end
      end
    end
  end
end
