# frozen_string_literal: true

RSpec.describe 'prosecution_cases/cd_api/_overall_defendants.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'prosecution_cases/cd_api/overall_defendants', locals: { results:, prosecution_case: }
  end

  let(:results) { [prosecution_case] }

  let(:prosecution_case) do
    build :prosecution_case, prosecution_case_reference: 'THECASEURN', overall_defendants:
  end

  let(:hearings) { [] }
  let(:overall_defendants) { [overall_defendant] }
  let(:defendant_name) { 'Joe Bloggs' }
  let(:overall_defendant) do
    build :overall_defendant, id: 'a-defendant-uuid', first_name: 'Joe', last_name: 'Bloggs',
                              maat_reference: '1234567', date_of_birth: '1968-07-14', name: ''
  end

  before do
    allow(overall_defendant).to receive(:name).and_return(defendant_name)
    assign(:prosecution_case, prosecution_case)
    assign(:results, results)
  end

  it { is_expected.to have_selector('.govuk-heading-l', text: 'Defendants') }

  it do
    is_expected
      .to have_selector('.govuk-table__header', text: 'Name')
      .and have_selector('.govuk-table__header', text: 'Date of birth')
      .and have_selector('.govuk-table__header', text: 'MAAT number')
  end

  it { is_expected.to have_link('Joe Bloggs') }
  it { is_expected.to have_selector('.govuk-table__cell', text: '14/07/1968') }
end
