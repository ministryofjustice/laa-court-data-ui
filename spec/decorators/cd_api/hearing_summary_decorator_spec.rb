# frozen_string_literal: true

RSpec.describe CdApi::HearingSummaryDecorator, type: :decorator do
  subject(:decorator) { described_class.new(hearing_summary, view_object) }

  let(:hearing_summary) { build :hearing_summary }
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
    let(:object) { hearing_summary }
  end

  context 'when method is missing' do
    before { allow(hearing_summary).to receive_messages(defence_counsels: nil) }

    it { is_expected.to respond_to(:defence_counsels) }
  end

  describe '#defence_counsel_list' do
    subject(:call) { decorator.defence_counsel_list }

    let(:hearing_summary) { build :hearing_summary, defence_counsels: }

    context 'with multiple defence_counsels' do
      let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
      let(:defence_counsel1) do
        build :defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior'
      end
      let(:defence_counsel2) { build :defence_counsel, first_name: 'Bob', last_name: 'Smith', status: 'QC' }

      it { is_expected.to eql('Jammy Dodger (Junior)<br>Bob Smith (QC)') }
    end

    context 'when there are multiple defendents in defence_counsels' do
      let(:hearing_summary) { build :hearing_summary, defence_counsels:, defendants: }
      let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
      let(:defence_counsel1) do
        build :defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior', defendants: defendant_ids
      end
      let(:defence_counsel2) { build :defence_counsel, first_name: 'Bob', last_name: 'Smith', status: 'QC' }

      let(:defendant_ids) do
        [defendant1, defendant2].map(&:id)
      end

      let(:defendants) { [defendant1, defendant2]}

      let(:defendant1) { build(:defendant, first_name: 'John', middle_name: '', last_name: 'Doe') }
      let(:defendant2) { build(:defendant, first_name: 'Jane', middle_name: '', last_name: 'Doe') }

      it 'returns defence counsel list' do
        expect(subject).to eql('Jammy Dodger (Junior) for John Doe<br>Jammy Dodger (Junior) for Jane Doe<br>Bob Smith (QC)')
      end
    end

    context 'with no defence_counsels' do
      let(:defence_counsels) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with missing defence_counsels details' do
      let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
      let(:defence_counsel1) do
        build :defence_counsel, first_name: '', middle_name: '', last_name: '', status: 'Junior'
      end
      let(:defence_counsel2) { build :defence_counsel, first_name: 'Bob', last_name: 'Smith', status: '' }

      it { is_expected.to eql ' (Junior)<br>Bob Smith ()' }
    end
  end

  describe '#hearing_days' do
    subject(:call) { decorator.hearing_days }

    let(:hearing_summary) { build :hearing_summary, hearing_days: }

    context 'with multiple hearing_days' do
      let(:hearing_days) { [hearing_day1, hearing_day2] }
      let(:hearing_day1) { build :hearing_day }
      let(:hearing_day2) { build :hearing_day }

      it { is_expected.to all(be_instance_of(CdApi::HearingDayDecorator)) }
    end

    context 'with no hearing_days' do
      let(:hearing_days) { [] }

      it { is_expected.to eql [] }
    end
  end
end
