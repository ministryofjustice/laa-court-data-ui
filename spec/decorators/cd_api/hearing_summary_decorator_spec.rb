# frozen_string_literal: true

RSpec.describe CdApi::HearingSummaryDecorator, type: :decorator do
  subject(:decorator) { described_class.new(hearing_summary, view_object) }

  let(:hearing_summary) { build(:hearing_summary) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
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

    let(:day) { '2022-05-17' }
    let(:formatted_date) { sitting_day.strftime('%Y-%m-%d') }
    let(:sitting_day) { DateTime.parse(day) }

    let(:hearing_summary) { build(:hearing_summary, defence_counsels:) }

    context 'when the summary has a specific day associated with it' do
      before do
        allow_any_instance_of(described_class).to receive(:day).and_return(sitting_day)
      end

      context 'when there are multiple defendants in defence_counsels' do
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:, defendants:) }
        let(:defence_counsels) { [defence_counsel1] }
        let(:defence_counsel1) do
          build(:defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior',
                                  defendants: defendant_ids, attendance_days: [formatted_date])
        end
        let(:defendant_ids) do
          [defendant1, defendant2].map(&:id)
        end

        let(:defendants) { [defendant1, defendant2] }

        let(:defendant1) { build(:defendant, first_name: 'John', middle_name: '', last_name: 'Doe') }
        let(:defendant2) { build(:defendant, first_name: 'Jane', middle_name: '', last_name: 'Doe') }

        before do
          allow_any_instance_of(described_class).to receive(:decorate_all).with(any_args).and_return([])
        end

        it 'maps defence_counsels defendants' do
          decorator.defence_counsel_list
          decorator.defence_counsels.each do |defence_counsel|
            expect(defence_counsel.defendants).to eq([defendant1, defendant2])
          end
        end
      end

      context 'with no defence_counsels' do
        let(:defence_counsels) { [] }

        it { is_expected.to eql 'Not available' }
      end

      context 'when defence counsels defendant ids fail to match' do
        let(:defence_counsels) { [defence_counsel] }
        let(:defence_counsel) do
          build(:defence_counsel, first_name: 'Bob', last_name: 'Smith', status: 'QC',
                                  defendants: [defendant.id])
        end
        let(:defendant) { build(:defendant) }
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:, defendants: []) }

        it 'returns defendant id' do
          decorator.defence_counsel_list
          decorator.defence_counsels.each do |defence_counsel|
            expect(defence_counsel.defendants).to eq([defendant.id])
          end
        end
      end

      context 'when defence counsel did not attend on the hearing day' do
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:) }

        let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
        let(:defence_counsel1) do
          build(:defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior',
                                  attendance_days: [formatted_date])
        end
        let(:defence_counsel2) do
          build(:defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior',
                                  attendance_days: ['2022-01-01'])
        end

        it 'returns defence counsels that attended on the hearing day' do
          expect_any_instance_of(described_class).to receive(:decorate_all).with([defence_counsel1], any_args)
          decorator.defence_counsel_list
        end
      end

      context 'when no defence counsels attended the hearing day' do
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:) }

        let(:defence_counsels) { [defence_counsel1] }
        let(:defence_counsel1) do
          build(:defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior',
                                  attendance_days: [])
        end

        it { is_expected.to eql 'Not available' }
      end

      context 'when called again after day has been altered' do
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:) }

        let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
        let(:defence_counsel1) do
          build(:defence_counsel, first_name: 'First', last_name: 'Counsel', status: 'Junior',
                                  attendance_days: ['2022-01-01'])
        end
        let(:defence_counsel2) do
          build(:defence_counsel, first_name: 'Second', last_name: 'Counsel', status: 'Junior',
                                  attendance_days: ['2022-01-01'])
        end

        before { decorator.defence_counsel_list }

        it 'returns new un-memoized defence counsel list' do
          allow_any_instance_of(described_class).to receive(:day).and_return(DateTime.parse('2022-01-01'))
          expect_any_instance_of(described_class).to receive(:decorate_all).with(
            [defence_counsel1, defence_counsel2], any_args
          )
          decorator.defence_counsel_list
        end
      end
    end

    context 'when there is no day associated with the hearing summary' do
      before do
        allow_any_instance_of(described_class).to receive(:day).and_return(nil)
      end

      context 'with no defence_counsels' do
        let(:defence_counsels) { [] }

        it { is_expected.to eql 'Not available' }
      end

      context 'when defence counsels attended on different days' do
        let(:hearing_summary) { build(:hearing_summary, defence_counsels:) }

        let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
        let(:defence_counsel1) do
          build(:defence_counsel, first_name: 'Jammy', last_name: 'Dodger', status: 'Junior',
                                  attendance_days: [formatted_date])
        end
        let(:defence_counsel2) do
          build(:defence_counsel, first_name: 'Hammy', last_name: 'Rodger', status: 'Senior',
                                  attendance_days: ['2022-01-01'])
        end

        it 'returns all defence counsels that attended on the hearing day' do
          expect(decorator.defence_counsel_list).to eq "Jammy Dodger (Junior)<br>Hammy Rodger (Senior)"
        end
      end
    end
  end

  describe '#hearing_days' do
    subject(:call) { decorator.hearing_days }

    let(:hearing_summary) { build(:hearing_summary, hearing_days:) }

    context 'with multiple hearing_days' do
      let(:hearing_days) { [hearing_day1, hearing_day2] }
      let(:hearing_day1) { build(:hearing_day) }
      let(:hearing_day2) { build(:hearing_day) }

      it { is_expected.to all(be_instance_of(CdApi::HearingDayDecorator)) }
    end

    context 'with no hearing_days' do
      let(:hearing_days) { [] }

      it { is_expected.to eql [] }
    end
  end

  describe '#formatted_estimated_duration' do
    subject(:call) { decorator.formatted_estimated_duration }

    context 'when there is an estimated duration' do
      it 'returns formated estimated duration in a sentence' do
        expect(call).to eq 'Estimated duration 20 days'
      end
    end

    context 'when there is no estimated duration' do
      let(:hearing_summary) { build(:hearing_summary, estimated_duration: nil) }

      it 'returns nil' do
        expect(call).to be_nil
      end
    end
  end
end
