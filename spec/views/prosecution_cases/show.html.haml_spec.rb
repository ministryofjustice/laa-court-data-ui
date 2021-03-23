# frozen_string_literal: true

RSpec.describe 'prosecution_cases/show.html.haml', type: :view do
  subject(:render_view) { render }

  let(:decorated_prosecution_case) { view.decorate(prosecution_case) }
  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase.new(prosecution_case_reference: 'THECASEURN')
  end

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    initialize_view_helpers(view)
    allow(view).to receive(:sort_column).and_return 'date'
    allow(view).to receive(:sort_direction).and_return 'asc'
    allow(prosecution_case).to receive(:hearings).and_return([])
    allow(prosecution_case).to receive(:defendants).and_return([])
    assign(:prosecution_case, decorated_prosecution_case)
  end

  it { is_expected.to have_content('A Gov uk page title') }
  it { is_expected.to render_template(:_cracked_ineffective_trial) }
  it { is_expected.to render_template(:_defendants) }
  it { is_expected.to render_template(:_hearing_summaries) }
end
