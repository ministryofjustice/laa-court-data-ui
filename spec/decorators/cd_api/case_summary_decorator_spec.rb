# frozen_string_literal: true

RSpec.describe CdApi::CaseSummaryDecorator, type: :decorator do
  subject(:decorator) { described_class.new(case_summary, view_object) }

  before do
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
  end

  let(:case_summary) { build(:case_summary) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { case_summary }
  end

  it {
    is_expected.to respond_to(:hearings_sort_column, :hearings_sort_column=, :hearings_sort_direction,
                              :hearings_sort_direction=)
  }

  context 'when method is missing' do
    before { allow(case_summary).to receive_messages(hearing_summaries: nil) }

    it { is_expected.to respond_to(:hearing_summaries) }
  end

  describe '#hearings' do
    subject(:call) { decorator.hearings }

    before { allow(case_summary).to receive(:hearings).and_return(hearing_summaries) }

    context 'with multiple v2 hearing_summaries' do
      let(:hearing_summaries) { [hearing_summary1, hearing_summary2] }
      let(:hearing_summary1) { build(:hearing_summary) }
      let(:hearing_summary2) { build(:hearing_summary) }

      it { is_expected.to all(be_instance_of(CdApi::HearingSummaryDecorator)) }
    end

    context 'with no hearing_summaries' do
      let(:hearing_summaries) { [] }

      it { is_expected.to be_empty }
    end
  end

  describe '#defendants' do
    subject(:call) { decorator.defendants }

    context 'with multiple overall defendants' do
      let(:case_summary) { build(:case_summary, :with_overall_defendants) }

      it { is_expected.to all(be_instance_of(CdApi::OverallDefendantDecorator)) }
    end

    context 'with no overall defendants' do
      let(:overall_defendants) { [] }

      it { is_expected.to be_empty }
    end
  end

  describe '#sorted_hearing_summaries_with_day' do
    subject(:call) { decorator.sorted_hearing_summaries_with_day }

    let(:decorator_class) { CdApi::HearingSummaryDecorator }
    let(:decorated_hearing_summaries) { [decorated_hearing1, decorated_hearing2, decorated_hearing3] }
    let(:decorated_hearing1) { view_object.decorate(hearing1, decorator_class) }
    let(:decorated_hearing2) { view_object.decorate(hearing2, decorator_class) }
    let(:decorated_hearing3) { view_object.decorate(hearing3, decorator_class) }
    let(:column) { 'date' }
    let(:direction) { 'asc' }
    let(:test_decorator) { decorator }

    before do
      allow(case_summary).to receive(:hearing_summaries).and_return(decorated_hearing_summaries)
      allow(decorated_hearing1).to receive(:defence_counsel_list).and_return(hearing1_defence_counsel_list)
      allow(decorated_hearing2).to receive(:defence_counsel_list).and_return(hearing2_defence_counsel_list)
      allow(decorated_hearing3).to receive(:defence_counsel_list).and_return(hearing3_defence_counsel_list)
      allow(test_decorator).to receive_messages(hearings_sort_column: column,
                                                hearings_sort_direction: direction)
    end

    it { is_expected.to be_instance_of(Enumerator) }
    it { is_expected.to all(be_instance_of(CdApi::HearingSummaryDecorator)) }

    include_examples 'sort v2 hearings'

    context 'when the hearings table sort column and direction are changed' do
      context 'when hearings_sort_column is date and hearings_sort_direction is asc' do
        let(:column) { 'date' }
        let(:direction) { 'asc' }
        let(:expected_days) do
          ['2021-01-18T11:00:00.000Z'.to_datetime,
           '2021-01-19T10:45:00.000Z'.to_datetime,
           '2021-01-20T16:00:00.000Z'.to_datetime,
           '2021-01-20T10:45:00.000Z'.to_datetime]
        end

        it 'sorts hearings by date asc' do
          expect(call.map(&:day))
            .to match(expected_days)
        end
      end

      context 'when hearings_sort_column is date and hearings_sort_direction is desc' do
        let(:column) { 'date' }
        let(:direction) { 'desc' }
        let(:expected_days) do
          ['2021-01-20T10:45:00.000Z'.to_datetime,
           '2021-01-20T16:00:00.000Z'.to_datetime,
           '2021-01-19T10:45:00.000Z'.to_datetime,
           '2021-01-18T11:00:00.000Z'.to_datetime]
        end

        it 'sorts hearings by date desc' do
          expect(call.map(&:day))
            .to match(expected_days)
        end
      end

      context 'when hearings_sort_column is type and hearings_sort_direction is asc' do
        let(:column) { 'type' }
        let(:direction) { 'asc' }

        it 'sorts hearings by type asc' do
          expect(call.map(&:hearing_type))
            .to match(['Mention', 'Pre-Trial Review', 'Trial', 'Trial'])
        end
      end

      context 'when hearings_sort_column is type and hearings_sort_direction is desc' do
        let(:column) { 'type' }
        let(:direction) { 'desc' }

        it 'sorts hearings by type desc' do
          expect(call.map(&:hearing_type))
            .to match(['Trial', 'Trial', 'Pre-Trial Review', 'Mention'])
        end
      end

      context 'when hearings_sort_column is provider and hearings_sort_direction is asc' do
        let(:column) { 'provider' }
        let(:direction) { 'asc' }

        it 'sorts hearings by provider asc' do
          expect(call.map(&:defence_counsel_list))
            .to match(['Custard Cream (Junior)', 'Hob Nob (QC)<br>Malted Milk (Junior)',
                       'Jammy Dodger (Junior)', 'Jammy Dodger (Junior)'])
        end
      end

      context 'when hearings_sort_column is provider and hearings_sort_direction is desc' do
        let(:column) { 'provider' }
        let(:direction) { 'desc' }

        it 'sorts hearings by provider desc' do
          expect(call.map(&:defence_counsel_list))
            .to match(['Jammy Dodger (Junior)', 'Jammy Dodger (Junior)',
                       'Hob Nob (QC)<br>Malted Milk (Junior)', 'Custard Cream (Junior)'])
        end
      end
    end
  end

  describe '#column_sort_icon' do
    subject(:call) { decorator.column_sort_icon }

    let(:test_decorator) { decorator }

    context 'when direction is asc' do
      before { allow(test_decorator).to receive(:hearings_sort_direction).and_return('asc') }

      it { is_expected.to eql("\u25B2") }
    end

    context 'when direction is desc' do
      before { allow(test_decorator).to receive(:hearings_sort_direction).and_return('desc') }

      it { is_expected.to eql("\u25BC") }
    end
  end

  describe '#column_title' do
    subject(:call) { decorator.column_title(column) }

    context 'when column is date' do
      let(:column) { 'date' }

      it { is_expected.to eql('Date') }
    end

    context 'when column is type' do
      let(:column) { 'type' }

      it { is_expected.to eql('Hearing type') }
    end

    context 'when column is provider' do
      let(:column) { 'provider' }

      it { is_expected.to eql('Providers attending') }
    end
  end

  describe '#hearings_sort_column' do
    subject(:call) { decorator.hearings_sort_column }

    context 'when hearings_sort_column has been set' do
      before { decorator.hearings_sort_column = 'type' }

      it 'returns the hearings_sort_column provided' do
        is_expected.to eql 'type'
      end
    end

    context 'when no hearings_sort_column set' do
      before { decorator.hearings_sort_column = nil }

      it 'returns the default hearings_sort_column' do
        is_expected.to eql 'date'
      end
    end
  end

  describe '#hearings_sort_direction' do
    subject(:call) { decorator.hearings_sort_direction }

    context 'when hearings_sort_direction has been set' do
      before { decorator.hearings_sort_direction = 'desc' }

      it 'returns the hearings_sort_direction provided' do
        is_expected.to eql 'desc'
      end
    end

    context 'when no hearings_sort_direction set' do
      before { decorator.hearings_sort_column = nil }

      it 'returns the default hearings_sort_column' do
        is_expected.to eql 'asc'
      end
    end
  end
end
