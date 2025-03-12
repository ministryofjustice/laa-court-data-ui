# frozen_string_literal: true

RSpec.describe CdApi::DefenceCounselDecorator, type: :decorator do
  subject(:decorator) { described_class.new(defence_counsel, view_object) }

  let(:defence_counsel) { build(:defence_counsel) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  before do
    allow(FeatureFlag).to receive(:enabled?).with(:hearing_summaries).and_return(true)
  end

  it_behaves_like 'a base decorator' do
    let(:object) { defence_counsel }
  end

  describe '#name_status_and_defendants' do
    subject(:call) { decorator.name_status_and_defendants }

    let(:defence_counsel) do
      build(:defence_counsel, first_name: 'Bob', last_name: 'Smith', status: 'QC',
                              defendants: mapped_defendants)
    end

    # The mapping of the defendants occurs in the HearingSummaryDecorator
    let(:mapped_defendants) do
      [build(:defendant, first_name: 'John', middle_name: nil, last_name: 'Doe')]
    end

    it { is_expected.to eql('Bob Smith (QC) for John Doe') }

    context 'when multiple defendants' do
      let(:mapped_defendants) do
        [build(:defendant, first_name: 'John', middle_name: nil, last_name: 'Doe'),
         build(:defendant, first_name: 'Jane', middle_name: nil, last_name: 'Doe')]
      end

      it 'displays the provider defendant relationship' do
        is_expected.to eql('Bob Smith (QC) for John Doe<br>Bob Smith (QC) for Jane Doe')
      end
    end

    context 'when defence counsel name and status is missing' do
      let(:defence_counsel) do
        build(:defence_counsel, first_name: '', middle_name: '', last_name: '', status: '',
                                defendants: mapped_defendants)
      end

      it { is_expected.to eql('Not available') }
    end

    context 'when defence counsel name is only partially given' do
      let(:defence_counsel) do
        build(:defence_counsel, first_name: 'Bob', middle_name: 'Owl', last_name: '', status: 'QC',
                                defendants: mapped_defendants)
      end

      it { is_expected.to eql('Bob Owl (QC) for John Doe') }
    end

    context 'when defence counsel name is missing' do
      let(:defence_counsel) do
        build(:defence_counsel, first_name: nil, middle_name: nil, last_name: nil, status: 'QC',
                                defendants: mapped_defendants)
      end

      it { is_expected.to eql('Not available (QC) for John Doe') }
    end

    context 'when defence counsel status is missing' do
      let(:defence_counsel) do
        build(:defence_counsel, first_name: 'Bob', middle_name: 'Owl', last_name: 'Smith', status: nil,
                                defendants: mapped_defendants)
      end

      it { is_expected.to eql('Bob Owl Smith (not available) for John Doe') }
    end

    context 'when defendants name is missing' do
      let(:defence_counsel) do
        build(:defence_counsel, first_name: 'Bob', middle_name: 'Owl', last_name: 'Smith', status: 'QC',
                                defendants: [])
      end

      it { is_expected.to eql('Bob Owl Smith (QC)') }
    end

    context 'when defendants name is partially missing' do
      let(:mapped_defendants) do
        [build(:defendant, first_name: 'John', middle_name: 'Jim', last_name: nil)]
      end

      it { is_expected.to eql('Bob Smith (QC) for John Jim') }
    end

    context 'when defendant_id to defendant_details match fails' do
      let(:mapped_defendants) { [nil, defendant.id] }
      let(:defendant) { build(:defendant, first_name: 'John', middle_name: 'Jim', last_name: nil) }

      it { is_expected.to eql('Bob Smith (QC) for not available<br>Bob Smith (QC) for not available') }
    end

    context 'when names are lower case' do
      let(:mapped_defendants) do
        [build(:defendant, first_name: 'john', middle_name: 'jim', last_name: 'jane')]
      end

      let(:defence_counsel) do
        build(:defence_counsel, first_name: 'bob', last_name: 'smith', status: 'qc',
                                defendants: mapped_defendants)
      end

      it { is_expected.to eql('Bob Smith (qc) for John Jim Jane') }
    end
  end
end
