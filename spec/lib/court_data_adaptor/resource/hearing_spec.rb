# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Hearing do
  let(:relations) { %i[providers hearing_events] }

  let(:properties) do
    %i[court_name
       day
       defendant_names
       hearing_days
       hearing_type
       id
       judge_names
       prosecution_advocate_names]
  end

  it_behaves_like 'court_data_adaptor acts_as_resource object', resource: described_class do
    let(:klass) { described_class }
    let(:instance) { described_class.new }
  end

  it_behaves_like 'court_data_adaptor resource object', test_class: described_class

  it_behaves_like 'court_data_adaptor resource callbacks' do
    let(:instance) { described_class.new }
  end

  it { is_expected.to respond_to(*relations) }
  it { is_expected.to respond_to(*properties) }

  describe '#defendant_names' do
    subject { instance.defendant_names }

    context 'when exists' do
      let(:instance) { described_class.new(defendant_names: ['Joe Bloggs', 'Fred Dibnah']) }

      it { is_expected.to contain_exactly('Joe Bloggs', 'Fred Dibnah') }
    end

    context 'when not exists' do
      let(:instance) { described_class.new }

      it { is_expected.to be_an(Array).and be_empty }
    end
  end
end
