# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view do
  subject(:render_view) { render }

  # rubocop: disable RSpec/VerifiedDoubles
  # NOTE: an instance double would require more setup
  # and we are only testing partials are rendered.
  let(:prosecution_case) do
    double(ProsecutionCaseDecorator,
           hearings: [hearing],
           prosecution_case_reference: 'ACASEURN',
           sorted_hearings_with_day: [hearing])
  end
  # rubocop: enable RSpec/VerifiedDoubles

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new(hearing_events: []) }
  let(:decorated_hearing) { view.decorate(hearing) }
  let(:paginator) { HearingPaginator.new(prosecution_case, sort_order: 'date_asc', page: '0') }

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(prosecution_case).to receive(:sort_order).and_return 'date_asc'
    assign(:hearing, decorated_hearing)
    assign(:paginator, paginator)
  end

  it { is_expected.to have_content('A Gov uk page title') }
  it { is_expected.to render_template(:_pagination) }
  it { is_expected.to render_template(:_listing_info) }
  it { is_expected.to render_template(:_attendees) }
  it { is_expected.to render_template(:_hearing_events) }
end
