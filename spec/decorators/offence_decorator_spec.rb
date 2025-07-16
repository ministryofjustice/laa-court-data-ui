# frozen_string_literal: true

RSpec.describe OffenceDecorator, type: :decorator do
  subject(:decorator) do
    described_class.new(offence, view_object).tap { it.offence_histories = offence_histories }
  end

  let(:offence) { instance_double(CourtDataAdaptor::Resource::Offence) }
  let(:offence_histories) { instance_double(Cda::OffenceHistoryCollection) }
  let(:offence_history) { Cda::OffenceHistory.new(pleas: nil, mode_of_trial_reasons: nil) }
  let(:view_object) { view_class.new }

  let(:plea_collection) { plea_array.map { |plea| CourtDataAdaptor::Resource::Plea.new(plea) } }
  let(:mot_reason_collection) do
    mode_of_trial_reason_array.map do |reason|
      CourtDataAdaptor::Resource::ModeOfTrialReason.new(reason)
    end
  end

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
    end
  end

  before do
    allow(offence_histories).to receive(:offence_histories).and_return([offence_history])
    allow(offence_history).to receive(:id).and_return('123')
    allow(offence).to receive(:id).and_return('123')
  end

  it_behaves_like 'a base decorator' do
    let(:object) { offence }
  end

  context 'when method is missing' do
    before do
      allow(offence)
        .to receive_messages(title: '',
                             legislation: '',
                             mode_of_trial: '')
      allow(offence_history)
        .to receive_messages(pleas: [],
                             mode_of_trial_reasons: [])
    end

    it { is_expected.to respond_to(:title, :legislation, :pleas, :mode_of_trial, :mode_of_trial_reasons) }
  end

  describe '#plea_list' do
    subject(:call) { decorator.plea_list }

    context 'when 1 or more pleas exist' do
      let(:plea_array) do
        [{ code: 'NOT_GUILTY',
           pleaded_at: '2020-01-01' },
         { code: 'GUILTY',
           pleaded_at: '2020-01-20' }]
      end

      before do
        allow(offence_history).to receive(:pleas).and_return(plea_collection)
      end

      it { is_expected.to eql('Not guilty on 01/01/2020<br>Guilty on 20/01/2020') }
    end

    context 'when pleas are not in pleaded_at order' do
      let(:plea_array) do
        [{ code: 'GUILTY',
           pleaded_at: '2020-02-01' },
         { code: 'NOT_GUILTY',
           pleaded_at: '2020-01-01' }]
      end

      before do
        allow(offence_history).to receive(:pleas).and_return(plea_collection)
      end

      it { is_expected.to eql 'Not guilty on 01/01/2020<br>Guilty on 01/02/2020' }
    end

    context 'when plea does not contain an expected key' do
      let(:plea_array) do
        [{ pleaded_at: '2020-01-20' },
         { pleaded_at: '2020-01-21' },
         { code: 'NOT_GUILTY' }]
      end

      let(:html_content) do
        ['Not guilty on Not available',
         'Not available on 20/01/2020',
         'Not available on 21/01/2020'].join('<br>')
      end

      before do
        allow(offence_history).to receive(:pleas).and_return(plea_collection)
      end

      it { is_expected.to eql html_content }
    end

    context 'when pleas are nil' do
      before do
        allow(offence_history).to receive(:pleas).and_return(nil)
      end

      it { is_expected.to eql 'Not available' }
    end

    context 'when pleas are empty' do
      before do
        allow(offence_history).to receive(:pleas).and_return([])
      end

      it { is_expected.to eql 'Not available' }
    end

    context 'when pleas are not enumerable' do
      before do
        allow(offence_history).to receive(:pleas).and_return('plea is a string')
      end

      it { expect { call }.not_to raise_error }
      it { is_expected.to eql('plea is a string') }
    end
  end

  describe '#start_date' do
    context 'when there is a start date' do
      before { allow(offence).to receive(:start_date).and_return("2023-01-05") }

      it "formats it" do
        expect(decorator.start_date).to eq "05/01/2023"
      end
    end

    context 'when there is no start date' do
      before { allow(offence).to receive(:start_date).and_return(nil) }

      it "returns nil" do
        expect(decorator.start_date).to be_nil
      end
    end
  end

  describe '#mode_of_trial_reason_list' do
    subject(:call) { decorator.mode_of_trial_reason_list }

    context 'when reasons exist' do
      before do
        allow(offence_history).to receive(:mode_of_trial_reasons).and_return(mot_reason_collection)
      end

      context 'when exactly one reason exists' do
        let(:mode_of_trial_reason_array) do
          [{ code: '4',
             description: 'Defendant elects trial by jury' }]
        end

        it { is_expected.to eql('Defendant elects trial by jury') }
      end

      context 'when more than one reason exists' do
        let(:mode_of_trial_reason_array) do
          [{ code: '5',
             description: 'Court directs trial by jury' },
           { code: '1',
             description: 'Summary-only offence' },
           { code: '2',
             description: 'Indictable-only offence' }]
        end

        it {
          is_expected.to eql('Court directs trial by jury<br>Summary-only offence<br>Indictable-only offence')
        }
      end
    end

    context 'when mode_of_trial_reasons does not contain an expected key' do
      before do
        allow(offence_history).to receive(:mode_of_trial_reasons).and_return(mot_reason_collection)
      end

      context 'when it does not contain a code' do
        let(:mode_of_trial_reason_array) do
          [{ description: 'Defendant elects trial by jury' }]
        end

        it { is_expected.to eql('Defendant elects trial by jury') }
      end

      context 'when it does not contain a description' do
        let(:mode_of_trial_reason_array) do
          [{ code: '4' }]
        end

        it { is_expected.to eql('Not available') }
      end
    end

    context 'when mode of trial reasons are nil' do
      before do
        allow(offence_history).to receive(:mode_of_trial_reasons).and_return(nil)
      end

      it { is_expected.to eql 'Not available' }
    end

    context 'when mode of trial reasons are empty' do
      before do
        allow(offence_history).to receive(:mode_of_trial_reasons).and_return([])
      end

      it { is_expected.to eql 'Not available' }
    end

    context 'when mode of trial reasons are not enumerable' do
      before do
        allow(offence_history).to receive(:mode_of_trial_reasons).and_return(
          'mode of trial reason is a string'
        )
      end

      it { expect { call }.not_to raise_error }
      it { is_expected.to eql('mode of trial reason is a string') }
    end
  end
end
