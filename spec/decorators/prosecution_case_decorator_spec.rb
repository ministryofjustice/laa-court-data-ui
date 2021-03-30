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

  it { is_expected.to respond_to(:column) }

  it { is_expected.to respond_to(:direction) }

  context 'when method is missing' do
    before { allow(prosecution_case).to receive_messages(hearings: nil) }

    it { is_expected.to respond_to(:hearings) }
  end

  describe '#hearings' do
    subject(:call) { decorator.hearings }

    before { allow(prosecution_case).to receive_messages(hearings: hearings) }

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

  describe '#sorted_hearings_with_day' do
    subject(:call) { decorator.sorted_hearings_with_day }

    let(:decorated_hearings) { [decorated_hearing1, decorated_hearing2, decorated_hearing3] }
    let(:decorated_hearing1) { view_object.decorate(hearing1) }
    let(:decorated_hearing2) { view_object.decorate(hearing2) }
    let(:decorated_hearing3) { view_object.decorate(hearing3) }
    let(:hearing1) do
      CourtDataAdaptor::Resource::Hearing.new(hearing_days: hearing1_days, hearing_type: 'Trial')
    end
    let(:hearing2) do
      CourtDataAdaptor::Resource::Hearing.new(hearing_days: hearing2_days, hearing_type: 'Mention')
    end
    let(:hearing3) do
      CourtDataAdaptor::Resource::Hearing.new(hearing_days: hearing3_days, hearing_type: 'Pre-Trial Review')
    end
    let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
    let(:hearing2_days) { ['2021-01-20T16:00:00.000Z'] }
    let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }

    before { allow(prosecution_case).to receive_messages(hearings: decorated_hearings) }

    it { is_expected.to be_instance_of(Enumerator) }
    it { is_expected.to all(be_instance_of(HearingDecorator)) }

    context 'when sort_colum is date and direction is asc' do
      before do
        allow(decorator).to receive(:column).and_return('date')
        allow(decorator).to receive(:direction).and_return('asc')
      end

      let(:expected_days) do
        ['2021-01-18T11:00:00.000Z'.to_datetime,
         '2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime,
         '2021-01-20T16:00:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end

    context 'when sort_colum is date and direction is desc' do
      before do
        allow(decorator).to receive(:column).and_return('date')
        allow(decorator).to receive(:direction).and_return('desc')
      end

      let(:expected_days) do
        ['2021-01-20T16:00:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime,
         '2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-18T11:00:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end

    context 'when sort_colum is type and direction is asc' do
      before do
        allow(decorator).to receive(:column).and_return('type')
        allow(decorator).to receive(:direction).and_return('asc')
      end

      let(:expected_days) do
        ['2021-01-20T16:00:00.000Z'.to_datetime,
         '2021-01-18T11:00:00.000Z'.to_datetime,
         '2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end

    context 'when sort_colum is type and direction is desc' do
      before do
        allow(decorator).to receive(:column).and_return('type')
        allow(decorator).to receive(:direction).and_return('desc')
      end

      let(:expected_days) do
        ['2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime,
         '2021-01-18T11:00:00.000Z'.to_datetime,
         '2021-01-20T16:00:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end

    context 'when sort_colum is provider and direction is asc' do
      before do
        allow(decorator).to receive(:column).and_return('provider')
        allow(decorator).to receive(:direction).and_return('asc')
        allow(decorated_hearing1).to receive(:provider_list).and_return('Jammy Dodger (Junior)')
        allow(decorated_hearing2).to receive(:provider_list).and_return('Custard Cream (QC)')
        allow(decorated_hearing3).to receive(:provider_list).and_return('Choc Digestive (QC)<br>Hob Nob (QC)')
      end

      let(:expected_days) do
        ['2021-01-18T11:00:00.000Z'.to_datetime,
         '2021-01-20T16:00:00.000Z'.to_datetime,
         '2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end

    context 'when sort_colum is provider and direction is desc' do
      before do
        allow(decorator).to receive(:column).and_return('provider')
        allow(decorator).to receive(:direction).and_return('desc')
        allow(decorated_hearing1).to receive(:provider_list).and_return('Jammy Dodger (Junior)')
        allow(decorated_hearing2).to receive(:provider_list).and_return('Custard Cream (QC)')
        allow(decorated_hearing3).to receive(:provider_list).and_return('Choc Digestive (QC)<br>Hob Nob (QC)')
      end

      let(:expected_days) do
        ['2021-01-19T10:45:00.000Z'.to_datetime,
         '2021-01-20T10:45:00.000Z'.to_datetime,
         '2021-01-20T16:00:00.000Z'.to_datetime,
         '2021-01-18T11:00:00.000Z'.to_datetime]
      end

      it { expect(call.map(&:day)).to eql(expected_days) }
    end
  end

  describe '#cracked?' do
    subject(:call) { decorator.cracked? }

    before { allow(prosecution_case).to receive_messages(hearings: hearings) }

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
end
