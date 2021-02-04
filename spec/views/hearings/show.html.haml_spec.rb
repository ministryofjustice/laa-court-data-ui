# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view do
  subject(:render_view) { render }

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    assign(:hearing, hearing)
    allow(hearing).to receive(:hearing_events).and_return([])
  end

  it { is_expected.to have_content('A Gov uk page title') }
  it { is_expected.to render_template(:_listing_info) }
  it { is_expected.to render_template(:_attendees) }
  it { is_expected.to render_template(:_hearing_events) }
end
