# frozen_string_literal: true

RSpec.describe Cda::ApplicationHearing do
  describe '#jurisdiction' do
    subject { described_class.new(data).jurisdiction }

    let(:data) { { jurisdiction_type: } }

    context 'when an invalid jurisdiction type' do
      let(:jurisdiction_type) { 'invalid' }

      it { is_expected.to eq 'Not available' }
    end

    context 'when a valid jurisdiction type' do
      let(:jurisdiction_type) { 'CROWN' }

      it { is_expected.to eq 'Crown Court' }
    end
  end
end
