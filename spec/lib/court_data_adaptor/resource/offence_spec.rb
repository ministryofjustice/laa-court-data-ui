# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Offence do
  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  include_examples 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new(defendant_id: nil) }
  end

  it { is_expected.to respond_to(:title, :plea, :plea_date, :mode_of_trial, :mode_of_trial_reason) }

  describe '#plea_and_date' do
    subject { instance.plea_and_date }

    let(:instance) { described_class.new(defendant_id: nil) }

    context 'when plea exists on offence' do
      before do
        allow(instance).to receive(:plea).and_return('NOT_GUILTY')
        allow(instance).to receive(:plea_date).and_return('2020-01-01')
      end

      it { is_expected.to eql 'Not guilty on 01/01/2020' }
    end

    context 'when plea does not exist on offence' do
      before do
        allow(instance).to receive(:plea).and_return(nil)
        allow(instance).to receive(:plea_date).and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end
end
