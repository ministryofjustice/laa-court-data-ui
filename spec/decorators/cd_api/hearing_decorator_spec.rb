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
    let(:hearing_details) { build :hearing_details }
    let(:hearing) { build :hearing, hearing: hearing_details }

    before do
      cracked_ineffective_trial = double(CdApi::CrackedIneffectiveTrial)
      allow(hearing).to receive(:hearing).and_return(hearing_details)
      allow(hearing_details).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial)
      allow(decorator).to receive(:decorate).with(hearing_details.cracked_ineffective_trial,
                                                  CdApi::CrackedIneffectiveTrialDecorator)
    end

    it 'decorates the hearings cracked_ineffective_trial' do
      decorator.cracked_ineffective_trial
      expect(decorator).to have_received(:decorate).with(hearing_details.cracked_ineffective_trial,
                                                         CdApi::CrackedIneffectiveTrialDecorator)
    end
  end

  describe '#defence_counsels_list' do
    let(:hearing) { build :hearing }
    let(:hearing_details) do
      build :hearing_details, defence_counsels:, prosecution_cases: [prosecution_case]
    end
    let(:prosecution_case) do
      build :hearing_prosecution_case, defendants: [hearing_defendant1, hearing_defendant2]
    end

    let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
    let(:defence_counsel1) do
      build :defence_counsel, defendants: hearing_defendants_ids, first_name: 'Jane', last_name: 'Doe'
    end
    let(:defence_counsel2) { build :defence_counsel }

    let(:hearing_defendants_ids) { [hearing_defendant1.id, hearing_defendant2.id] }
    let(:hearing_defendant1) { build :hearing_defendant, :with_defendant_details }
    let(:hearing_defendant2) { build :hearing_defendant, :with_defendant_details }

    before do
      allow(hearing).to receive(:hearing).and_return(hearing_details)
      allow(CdApi::Hearing::DefenceCounselsListService).to receive(:call).with(hearing_details.defence_counsels).and_return([])
      decorator.defence_counsels_list
    end

    it 'maps defendants in defence counsels' do
      decorator.hearing.defence_counsels.each do |defence_counsel|
        expect(defence_counsel.defendants).to all(be_a(CdApi::Defendant))
      end
    end

    it 'calls CdApi::Hearing::DefenceCounselsListService' do
      expect(CdApi::Hearing::DefenceCounselsListService).to have_received(:call).with(hearing_details.defence_counsels)
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
        defendants = decorator.hearing.defence_counsels.map(&:defendants)
        expect(defendants).to eq [hearing_defendants_ids]
      end
    end

    context 'when defence counsels have no defendants' do
      let(:defence_counsels) { [defence_counsel1] }
      let(:prosecution_case) { build :hearing_prosecution_case, defendants: [] }
      let(:defence_counsel1) do
        build :defence_counsel, defendants: [], first_name: 'Jane', last_name: 'Doe'
      end

      it 'returns empty array' do
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

      let(:defence_counsel1) do
        build :defence_counsel, defendants: [hearing_defendant1.id], first_name: 'Jane', last_name: 'Doe'
      end
      let(:defence_counsel2) do
        build :defence_counsel, defendants: [hearing_defendant2.id], first_name: 'John', last_name: 'ABCDE'
      end

      it 'maps defendants in defence counsels' do
        decorator.hearing.defence_counsels.each do |defence_counsel|
          expect(defence_counsel.defendants).to all(be_a(CdApi::Defendant))
        end
      end
    end
  end
end
