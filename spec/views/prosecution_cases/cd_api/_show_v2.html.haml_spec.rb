# frozen_string_literal: true

RSpec.describe 'prosecution_cases/cd_api/_show_v2.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'prosecution_cases/cd_api/show_v2', locals: { case_summary: decorated_case_summary }
  end

  let(:decorated_case_summary) { view.decorate(case_summary, CdApi::CaseSummaryDecorator) }
  let(:case_summary) do
    build :case_summary, prosecution_case_reference: ''
  end

  before do
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(decorated_case_summary).to receive(:hearings_sort_column).and_return 'date'
    allow(decorated_case_summary).to receive(:hearings_sort_direction).and_return 'asc'
    allow(decorated_case_summary).to receive(:prosecution_case_reference).and_return 'TEST12345'
    # assign(:case_summary, decorated_case_summary)
  end

  it { is_expected.to render_template(:_overall_defendants) }
  it { is_expected.to render_template(:_hearing_summaries) }
end
