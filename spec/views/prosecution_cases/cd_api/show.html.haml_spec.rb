# frozen_string_literal: true

RSpec.describe 'prosecution_cases/cd_api/_show_v2.html.haml', type: :view do
  subject(:render_view) { render }

  let(:decorated_prosecution_case) { view.decorate(prosecution_case, CdApi::ProsecutionCaseDecorator) }
  let(:prosecution_case) do
    build :prosecution_case, prosecution_case_reference: ''
  end

  before do
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(decorated_prosecution_case).to receive(:hearings_sort_column).and_return 'date'
    allow(decorated_prosecution_case).to receive(:hearings_sort_direction).and_return 'asc'
    allow(decorated_prosecution_case).to receive(:prosecution_case_reference).and_return 'TEST12345'
    assign(:prosecution_case, decorated_prosecution_case)
  end

  it { is_expected.to render_template(:_overall_defendants) }
  it { is_expected.to render_template(:_hearing_summaries) }
end
