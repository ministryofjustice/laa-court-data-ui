# frozen_string_literal: true

RSpec.describe CdApi::DefendantsDecorator, type: :decorator do
  subject(:decorator) { described_class.new(defendants, view_object) }

  let(:defendants) { build(:hearing_defendant, :with_defendant_details) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  before do
    allow(Feature).to receive(:enabled?).with(:judicial_results).and_return(true)
  end

  it_behaves_like 'a base decorator' do
    let(:object) { defendants }
  end

  describe 'defendant name' do
    subject(:call) { decorator.defendant_name }

    context 'when defendant present' do
      it 'displays the full name' do
        is_expected.to eql 'Vince James'
      end
    end
  end

  describe 'judicial_results_list' do
    subject(:call) { decorator.judicial_results_list }

    context 'when results not present' do
      it 'provides an empty list' do
        is_expected.to eql []
      end
    end

    context 'when results present' do
      let(:defendants) { build(:hearing_defendant, :with_defendant_details, :with_offences_and_results) }

      it 'provides decorated entries' do
        is_expected.to all(be_a(CdApi::JudicialResultsDecorator))
      end

      it 'has one entry' do
        is_expected.to have_attributes(size: 1)
      end
    end
  end
end
