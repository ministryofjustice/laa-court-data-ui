# frozen_string_literal: true

RSpec.describe CdApi::HearingDecorator, type: :decorator do
  subject(:decorator) { described_class.new(hearing, view_object) }

  let(:hearing) { build :hearing }
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
    let(:object) { hearing }
  end

  describe '#cracked_ineffective_trial' do
    let(:hearing_details) { build :hearing_details, cracked_ineffective_trial: }
    let(:hearing) { build :hearing, hearing: hearing_details }
    let(:cracked_ineffective_trial) { instance_double(CdApi::CrackedIneffectiveTrial) }

    before do
      allow(hearing).to receive(:hearing).and_return(hearing_details)
    end

    it 'decorates the hearings cracked_ineffective_trial' do
      decorator_class = CdApi::CrackedIneffectiveTrialDecorator
      expect(decorator.cracked_ineffective_trial).to be_an_instance_of(decorator_class)
    end
  end

  describe '#defence_counsels_list' do
    let(:hearing_details) do
      build :hearing_details, defence_counsels:, prosecution_cases: [prosecution_case],
                              hearing_days: [hearing_day1]
    end
    let(:hearing_day1) { build(:hearing_day) }
    let(:prosecution_case) do
      build :hearing_prosecution_case, defendants: [hearing_defendant1, hearing_defendant2]
    end

    let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
    let(:defence_counsel1) do
      build :defence_counsel, defendants: [hearing_defendant1.id, hearing_defendant2.id], first_name: 'Jane',
                              last_name: 'Doe', attendance_days: [day]
    end
    let(:defence_counsel2) { build :defence_counsel, attendance_days: [day] }

    let(:hearing_defendant1) { build :hearing_defendant, :with_defendant_details }
    let(:hearing_defendant2) { build :hearing_defendant, :with_defendant_details }
    let(:day) { hearing_day1.sitting_day.strftime('%Y-%m-%d') }

    let(:mapped_defence_counsels) { hearing_details.defence_counsels }

    before do
      allow(hearing).to receive(:hearing).and_return(hearing_details)
      allow(CdApi::HearingDetails::DefenceCounselsListService).to receive(:call)
        .with(mapped_defence_counsels).and_return([])
      allow_any_instance_of(described_class).to receive(:current_sitting_day).and_return(day)
    end

    it 'maps defendants in defence counsels' do
      decorator.defence_counsels_list
      decorator.hearing.defence_counsels.each do |defence_counsel|
        expect(defence_counsel.defendants).to all(be_a(CdApi::Defendant))
      end
    end

    it 'calls CdApi::Hearing::DefenceCounselsListService' do
      decorator.defence_counsels_list
      service = CdApi::HearingDetails::DefenceCounselsListService
      expect(service).to have_received(:call).with(hearing_details.defence_counsels)
    end

    context 'when defence counsels are empty' do
      let(:hearing_details) do
        build :hearing_details, defence_counsels: [], prosecution_cases: [prosecution_case]
      end

      it 'returns not available' do
        expect(decorator.defence_counsels_list).to eq 'Not available'
      end
    end

    context 'when prosecution case is missing the defendant information' do
      let(:defence_counsels) { [defence_counsel1] }
      let(:prosecution_case) { build :hearing_prosecution_case, defendants: [] }

      it 'returns array with defendant ids' do
        decorator.defence_counsels_list
        defendants = decorator.hearing.defence_counsels.map(&:defendants)
        expect(defendants).to eq [[hearing_defendant1.id, hearing_defendant2.id]]
      end
    end

    context 'when defence counsels have no defendants' do
      let(:defence_counsels) { [defence_counsel1] }
      let(:prosecution_case) { build :hearing_prosecution_case, defendants: [] }
      let(:defence_counsel1) do
        build :defence_counsel, defendants: [], first_name: 'Jane', last_name: 'Doe', attendance_days: [day]
      end

      it 'returns empty array' do
        decorator.defence_counsels_list
        defendants = decorator.hearing.defence_counsels.map(&:defendants)
        expect(defendants).to eq [[]]
      end
    end

    context 'when there are two prosecution cases' do
      let(:hearing_details) do
        build :hearing_details, defence_counsels:, prosecution_cases: [prosecution_case1, prosecution_case2]
      end
      let(:prosecution_case1) do
        build :hearing_prosecution_case, defendants: [hearing_defendant1]
      end
      let(:prosecution_case2) do
        build :hearing_prosecution_case, defendants: [hearing_defendant2]
      end

      it 'maps defendants in defence counsels' do
        decorator.defence_counsels_list
        decorator.hearing.defence_counsels.each do |defence_counsel|
          expect(defence_counsel.defendants).to all(be_a(CdApi::Defendant))
        end
      end
    end

    context 'when the defence counsel did not attend the hearing day' do
      let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
      let(:defence_counsel1) do
        build :defence_counsel, defendants: [hearing_defendant1.id, hearing_defendant2.id],
                                first_name: 'Jane', last_name: 'Doe', attendance_days: [day]
      end
      let(:defence_counsel2) do
        build :defence_counsel, first_name: 'John', last_name: 'Smith', attendance_days: []
      end

      before do
        allow(CdApi::HearingDetails::DefenceCounselsListService).to receive(:call)
          .with([defence_counsel1]).and_return([])
        decorator.defence_counsels_list
      end

      it 'does not add the defence counsel to the list' do
        service = CdApi::HearingDetails::DefenceCounselsListService
        expect(service).to have_received(:call).with([defence_counsel1])
      end
    end

    context 'when there is no current_sitting_day' do
      let(:mapped_defence_counsels) { [] }
      let(:day) { nil }

      it 'does not add the defence counsel to the list' do
        decorator.defence_counsels_list
        service = CdApi::HearingDetails::DefenceCounselsListService
        expect(service).to have_received(:call).with([])
      end
    end
  end
end
