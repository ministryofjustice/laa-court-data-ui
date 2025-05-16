# frozen_string_literal: true

RSpec.describe Cda::HearingDetails::DefenceCounselsListService do
  describe '#call' do
    subject(:case_service_call) { described_class.call(defence_counsels, map_counsels_to_defendants:) }

    let(:defence_counsels) { [defence_counsel1, defence_counsel2] }
    let(:defence_counsel1) do
      build(:defence_counsel, defendants: [hearing_defendant1, hearing_defendant2], first_name: 'Jane',
                              last_name: 'Doe')
    end
    let(:defence_counsel2) { build(:defence_counsel) }

    let(:hearing_defendant1) { build(:hearing_defendant, :with_defendant_details) }
    let(:hearing_defendant2) { build(:hearing_defendant, :with_defendant_details) }
    let(:map_counsels_to_defendants) { true }

    context 'when defence counsel has multiple defendants' do
      let(:defence_counsels) { [defence_counsel1, defence_counsel2, defence_counsel3, defence_counsel4] }
      let(:defence_counsel3) do
        build(:defence_counsel, first_name: 'Jim', last_name: 'Cleo',
                                defendants: [hearing_defendant1, hearing_defendant2])
      end
      let(:defence_counsel4) { build(:defence_counsel, first_name: 'Ab', last_name: 'Ba', status: 'QC') }

      it 'returns list of defence_counsels paired with their defendants' do
        expect(case_service_call).to eq(['Jane Doe (Junior) for Vince James',
                                         'Jane Doe (Junior) for Vince James',
                                         'John Smith (Junior)', 'Jim Cleo (Junior) for Vince James',
                                         'Jim Cleo (Junior) for Vince James', 'Ab Ba (QC)'])
      end
    end

    context 'when names are lower case' do
      let(:hearing_defendant1) { build(:hearing_defendant, defendant_details:) }
      let(:defendant_details) { build(:hearing_defendant_details, person_details:) }
      let(:person_details) do
        build(:hearing_person_details, first_name: 'john', middle_name: 'doe', last_name: 'smith')
      end

      let(:defence_counsel1) do
        build(:defence_counsel, defendants: [hearing_defendant1, hearing_defendant2], first_name: 'jane',
                                last_name: 'doe', status: 'junior')
      end

      it 'capitalizes the names' do
        expect(case_service_call).to eq(['Jane Doe (junior) for John Doe Smith',
                                         'Jane Doe (junior) for Vince James', 'John Smith (Junior)'])
      end
    end

    context 'when there are no defence counsels' do
      let(:defence_counsels) { nil }

      it 'returns empty list' do
        expect(case_service_call).to be_empty
      end
    end

    context 'when there are no defendants' do
      let(:defence_counsels) { [defence_counsel] }
      let(:defence_counsel) { build(:defence_counsel, first_name: 'John', last_name: 'Doe', status: 'QC') }

      it 'returns empty list' do
        expect(case_service_call).to eq(['John Doe (QC)'])
      end
    end

    context 'when defendant is an id' do
      let(:defence_counsels) { [defence_counsel1] }
      let(:defence_counsel1) do
        build(:defence_counsel, defendants: [hearing_defendant1.id, hearing_defendant2.id],
                                first_name: 'Jane', last_name: 'Doe', status: 'QC')
      end

      it 'returns defence counsel list with unavailable defendant details' do
        expect(case_service_call).to eq(['Jane Doe (QC) for not available',
                                         'Jane Doe (QC) for not available'])
      end

      context "when not mapping to defendants" do
        let(:map_counsels_to_defendants) { false }

        it 'returns deduplicated defence counsel list with no defendant details' do
          expect(case_service_call).to eq(['Jane Doe (QC)'])
        end
      end
    end
  end
end
