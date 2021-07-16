# frozen_string_literal: true

RSpec.describe CourtDataAdaptor::Resource::Offence do
  let(:plea_ostruct_collection) { plea_array.map { |el| OpenStruct.new(el) } }
  let(:mot_reason_ostruct_collection) { mode_of_trial_array.map { |el| OpenStruct.new(el) } }

  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  include_examples 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new(defendant_id: nil) }
  end

  it { is_expected.to respond_to(:title, :legislation, :pleas, :mode_of_trial, :mode_of_trial_reasons) }

  describe '#pleas' do
    subject(:pleas) { instance.pleas }

    let(:instance) { described_class.new(defendant_id: nil) }
    let(:plea_array) { [{ code: 'NOT_GUILTY', pleaded_at: '2020-01-01' }] }

    it { is_expected.to be_an Array }

    context 'when empty' do
      before { allow(instance).to receive(:pleas).and_call_original }

      it { is_expected.to be_empty }
    end

    context 'when 1 or more pleas exist' do
      before { allow(instance).to receive(:pleas).and_return(plea_ostruct_collection) }

      it { is_expected.to be_present }
      it { is_expected.to all(be_an(OpenStruct)) }
      it { is_expected.to all(respond_to(:code, :pleaded_at)) }
    end
  end

  describe '#mode_of_trial_reasons' do
    subject(:mode_of_trial_reasons) { instance.mode_of_trial_reasons }

    let(:instance) { described_class.new(defendant_id: nil) }
    let(:mode_of_trial_array) { [{ code: '4', description: 'Defendant elects trial by jury' }] }

    it { is_expected.to be_an Array }

    context 'when empty' do
      before { allow(instance).to receive(:mode_of_trial_reasons).and_call_original }

      it { is_expected.to be_empty }
    end

    context 'when 1 or more mode of trial reasons exist' do
      before { allow(instance).to receive(:mode_of_trial_reasons).and_return(mot_reason_ostruct_collection) }

      it { is_expected.to be_present }
      it { is_expected.to all(be_an(OpenStruct)) }
      it { is_expected.to all(respond_to(:code, :description)) }
    end
  end
end
