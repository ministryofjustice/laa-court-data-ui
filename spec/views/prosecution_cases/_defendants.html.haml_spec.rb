# frozen_string_literal: true

RSpec.describe 'prosecution_cases/_defendants.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'defendants', locals: { results:, prosecution_case: }
  end

  let(:results) { [prosecution_case] }

  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase
      .new(prosecution_case_reference: 'THECASEURN')
  end

  let(:hearings) { [] }
  let(:defendants) { [defendant] }
  let(:defendant) do
    CourtDataAdaptor::Resource::Defendant
      .new(id: 'a-defendant-uuid',
           name: 'Joe Bloggs',
           maat_reference: '1234567',
           date_of_birth: '1968-07-14')
  end

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(prosecution_case).to receive_messages(hearings:, defendants:)
    assign(:prosecution_case, prosecution_case)
    assign(:results, results)
  end

  it { is_expected.to have_css('.govuk-heading-l', text: 'Defendants') }

  it do
    is_expected
      .to have_css('.govuk-table__header', text: 'Name')
      .and have_css('.govuk-table__header', text: 'Date of birth')
      .and have_css('.govuk-table__header', text: 'MAAT number')
  end

  it { is_expected.to have_link('Joe Bloggs') }
  it { is_expected.to have_css('.govuk-table__cell', text: '14/07/1968') }
end
