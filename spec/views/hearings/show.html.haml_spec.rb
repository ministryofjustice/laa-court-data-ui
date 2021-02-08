# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view do
  subject(:render_view) { render }

  let(:prosecution_case) { CourtDataAdaptor::Resource::ProsecutionCase.new }
  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_days: []) }
  let(:paginator) { HearingPaginator.new(prosecution_case, page: '0') }

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(prosecution_case).to receive(:hearings).and_return([hearing])
    allow(hearing).to receive(:hearing_events).and_return([])
    assign(:hearing, hearing)
    assign(:paginator, paginator)
  end

  it { is_expected.to have_content('A Gov uk page title') }
  it { is_expected.to render_template(:_pagination) }
  it { is_expected.to render_template(:_listing_info) }
  it { is_expected.to render_template(:_attendees) }
  it { is_expected.to render_template(:_hearing_events) }
end
