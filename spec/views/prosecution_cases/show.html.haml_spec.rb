# frozen_string_literal: true

RSpec.describe 'prosecution_cases/show.html.haml', type: :view do
  subject(:render_partial) do
    render locals: { prosecution_case: decorated_case_summary }
  end

  let(:decorated_case_summary) { view.decorate(case_summary, Cda::CaseSummaryDecorator) }
  let(:case_summary) do
    build(:prosecution_case, prosecution_case_reference: '')
  end

  let(:case_summary_details) do
    {
      hearings_sort_column: 'date',
      hearings_sort_direction: 'asc',
      prosecution_case_reference: 'TEST12345'
    }
  end

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(decorated_case_summary).to receive_messages(case_summary_details)
  end

  it { is_expected.to render_template(:_overall_defendants) }
  it { is_expected.to render_template(:_hearing_summaries) }
end
