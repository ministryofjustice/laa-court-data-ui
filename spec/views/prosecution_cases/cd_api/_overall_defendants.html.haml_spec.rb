# frozen_string_literal: true

RSpec.describe 'prosecution_cases/cd_api/_overall_defendants.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'prosecution_cases/cd_api/overall_defendants', locals: { results:, case_summary: }
  end

  let(:results) { [case_summary] }

  let(:case_summary) do
    view.decorate(build(:prosecution_case, prosecution_case_reference: 'THECASEURN', defendant_summaries:),
                  Cda::CaseSummaryDecorator)
  end

  let(:hearings) { [] }
  let(:defendant_summaries) { [overall_defendant] }
  let(:overall_defendant) do
    build(:defendant_summary, id: 'a-defendant-uuid', first_name: 'Joe', last_name: 'Bloggs',
                              middle_name: "X",
                              maat_reference: '1234567', date_of_birth: '1968-07-14')
  end

  before do
    assign(:case_summary, case_summary)
    assign(:results, results)
  end

  it { is_expected.to have_css('.govuk-heading-l', text: 'Defendants') }

  it do
    is_expected
      .to have_css('.govuk-table__header', text: 'Name')
      .and have_css('.govuk-table__header', text: 'Date of birth')
      .and have_css('.govuk-table__header', text: 'MAAT number')
  end

  it { is_expected.to have_link('Joe X Bloggs') }
  it { is_expected.to have_css('.govuk-table__cell', text: '14/07/1968') }
end
