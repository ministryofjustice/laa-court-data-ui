# frozen_string_literal: true

RSpec.describe ProsecutionCaseDecorator, type: :decorator do
  subject(:decorator) { described_class.new(prosecution_case, view_object) }

  let(:prosecution_case) { instance_double(CourtDataAdaptor::Resource::ProsecutionCase) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { prosecution_case }
  end

  it {
    is_expected.to respond_to(:hearings_sort_column, :hearings_sort_column=, :hearings_sort_direction,
                              :hearings_sort_direction=)
  }

  context 'when :hearings method is missing from the decorator' do
    before { allow(prosecution_case).to receive_messages(hearings: nil) }

    it 'gets response from :hearings on the object' do
      expect(prosecution_case).to respond_to(:hearings)
    end
  end

  describe '#hearings' do
    subject(:call) { decorator.hearings }

    before { allow(prosecution_case).to receive_messages(hearings:) }

    context 'with multiple hearings' do
      let(:hearings) { [hearing1, hearing2] }
      let(:hearing1) { CourtDataAdaptor::Resource::Hearing.new }
      let(:hearing2) { CourtDataAdaptor::Resource::Hearing.new }

      it { is_expected.to all(be_instance_of(HearingDecorator)) }
    end

    context 'with no hearings' do
      let(:hearings) { [] }

      it { is_expected.to be_empty }
    end
  end

  describe '#cracked?' do
    subject(:call) { decorator.cracked? }

    before { allow(prosecution_case).to receive_messages(hearings:) }

    context 'with no hearings' do
      let(:hearings) { [] }

      it { is_expected.to be_falsey }
    end

    context 'with a hearing without a "cracked" cracked_ineffective_trial object' do
      let(:hearings) { [hearing] }
      let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
      let(:cracked_ineffective_trial) do
        CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new(type: 'Ineffective')
      end

      it { is_expected.to be_falsey }
    end

    context 'with a hearing with a "cracked" cracked_ineffective_trial object' do
      let(:hearings) { [hearing] }
      let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
      let(:cracked_ineffective_trial) do
        CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new(type: 'Cracked')
      end

      before do
        allow(hearing).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial)
      end

      it { is_expected.to be_truthy }
    end

    context 'with multiple hearings with one "cracked" cracked_ineffective_trial object' do
      let(:hearings) { [hearing1, hearing2] }
      let(:hearing1) { CourtDataAdaptor::Resource::Hearing.new }
      let(:hearing2) { CourtDataAdaptor::Resource::Hearing.new }
      let(:cracked_ineffective_trial1) do
        CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new(type: 'Vacated', code: 'A')
      end
      let(:cracked_ineffective_trial2) do
        CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new(type: 'Ineffective', code: 'M1')
      end

      before do
        allow(hearing1).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial1)
        allow(hearing2).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial2)
      end

      it { is_expected.to be_truthy }
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
