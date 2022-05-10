# frozen_string_literal: true

RSpec.describe CdApi::DefenceCounselDecorator, type: :decorator do
  subject(:decorator) { described_class.new(defence_counsel, view_object) }

  let(:defence_counsel) { build :defence_counsel }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  before do
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
  end

  it_behaves_like 'a base decorator' do
    let(:object) { defence_counsel }
  end

  describe '#name_and_status' do
    subject(:call) { decorator.name_and_status }

    let(:defence_counsel) { build :defence_counsel, first_name: 'Bob', last_name: 'Smith', status: 'QC' }

    it { is_expected.to eql('Bob Smith (QC)') }

    context 'when name and status is missing' do
      let(:defence_counsel) do
        build :defence_counsel, first_name: '', middle_name: '', last_name: '', status: ''
      end

      it { is_expected.to eql('Not available') }
    end

    context 'when name is only partially given' do
      let(:defence_counsel) do
        build :defence_counsel, first_name: 'Bob', middle_name: 'Owl', last_name: '', status: 'QC'
      end

      it { is_expected.to eql('Bob Owl (QC)') }
    end

    context 'when name is missing' do
      let(:defence_counsel) do
        build :defence_counsel, first_name: nil, middle_name: nil, last_name: nil, status: 'QC'
      end

      it { is_expected.to eql('Not available (QC)') }
    end

    context 'when status is missing' do
      let(:defence_counsel) do
        build :defence_counsel, first_name: 'Bob', middle_name: 'Owl', last_name: 'Smith', status: nil
      end

      it { is_expected.to eql('Bob Owl Smith (not available)') }
    end
  end
end
