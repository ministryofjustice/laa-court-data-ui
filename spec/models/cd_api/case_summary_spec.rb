# frozen_string_literal: true

RSpec.describe CdApi::CaseSummary, :stub_v2_hearing_summary, type: :model do
  subject(:case_summary) do
    described_class.find(case_reference)
  end

  let(:case_reference) { 'TEST12345' }

  it { is_expected.to respond_to(:prosecution_case_reference, :hearing_summaries, :overall_defendants) }
end
