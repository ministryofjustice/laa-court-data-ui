# frozen_string_literal: true

RSpec.describe CdApi::JudicialResultsDecorator, type: :decorator do
  subject(:decorator) { described_class.new(judicial_results, view_object) }

  let(:judicial_results) { build(:judicial_results) }
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
    let(:object) { judicial_results }
  end

  describe 'formatted_date' do
    subject(:call) { decorator.formatted_date }

    it 'formats the date' do
      is_expected.to eq '22/10/2021'
    end
  end
end
