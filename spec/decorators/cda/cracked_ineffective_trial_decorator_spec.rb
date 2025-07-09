# frozen_string_literal: true

RSpec.describe Cda::CrackedIneffectiveTrialDecorator, type: :decorator do
  subject(:decorator) { described_class.new(cracked_ineffective_trial, view_object) }

  let(:cracked_ineffective_trial) { build(:cracked_ineffective_trial) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { cracked_ineffective_trial }
  end

  context 'when method is missing' do
    before { allow(cracked_ineffective_trial).to receive_messages(type: nil, code: nil) }

    it { is_expected.to respond_to(:type, :code) }
  end

  describe '#cracked_on_sentence' do
    subject(:call) { decorator.cracked_on_sentence(hearing.hearing) }

    let(:hearing) { build(:hearing, hearing: hearing_details) }
    let(:hearing_details) { build(:hearing_details, :with_hearing_days) }

    before do
      allow(cracked_ineffective_trial).to receive_messages(type:)
    end

    context 'when type is cracked' do
      let(:type) { 'CrACKed' }

      it { is_expected.to include('Cracked on 19 January 2021') }
    end

    context 'when type is vacated' do
      let(:type) { 'Vacated' }

      it { is_expected.to include('Vacated on 19 January 2021') }
    end
  end

  describe '#description_sentence' do
    subject(:call) { decorator.description_sentence }

    before do
      allow(cracked_ineffective_trial)
        .to receive_messages(type: 'IneFFectiVE',
                             description: 'Another case over-ran')
    end

    it { is_expected.to eql('<strong>Ineffective</strong>: Another case over-ran') }
  end
end
