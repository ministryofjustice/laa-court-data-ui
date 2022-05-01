# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view, stub_v2_hearing_data: true do
  subject(:render_view) { render }

  # rubocop: disable RSpec/VerifiedDoubles
  # NOTE: an instance double would require more setup
  # and we are only testing partials are rendered.
  # Hope to remove with future V2 improvements
  let(:prosecution_case) do
    double(ProsecutionCaseDecorator,
           hearings: [hearing_v1],
           prosecution_case_reference: 'ACASEURN',
           sorted_hearings_with_day: [hearing_v1],
           hearings_sort_column: 'date',
           hearings_sort_direction: 'asc')
  end
  # rubocop: enable RSpec/VerifiedDoubles

  let(:hearing_v1) { CourtDataAdaptor::Resource::Hearing.new(hearing_events: []) }
  let(:decorated_hearing) { view.decorate(hearing_v1) }

  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing_events) do
    CdApi::HearingEvents.find(hearing_id,
                              params: { date: hearing_day.strftime('%F') })
  end
  let(:hearing) do
    CdApi::Hearing.find(hearing_id)
  end
  let(:paginator) do
    HearingPaginator.new(prosecution_case, column: 'date', direction: 'asc', page: '0')
  end

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(false)
    allow(Feature).to receive(:enabled?).with(:hearing_data).and_return(true)
    allow(Feature).to receive(:enabled?).with(:hearing_events).and_return(true)

    allow(view).to receive(:govuk_page_title).and_return 'Hearings Page'
    allow(prosecution_case).to receive(:hearings_sort_column=)
    allow(prosecution_case).to receive(:hearings_sort_direction=)
    assign(:hearing, hearing)
    assign(:paginator, paginator)
  end

  context 'when viewing hearing details' do
    it 'displays the v2 partial' do
      is_expected.to render_template('hearings/_details_v2')
    end
  end

  context 'when viewing attendees' do
    it 'displays the v2 partial' do
      is_expected.to render_template('hearings/_attendees_v2')
    end
  end

  context 'when viewing results' do
    it 'displays the v2 partial' do
      is_expected.to render_template('hearings/_hearing_result_v2')
    end
  end

  context 'when viewing court applications' do
    it 'displays the v2 partial' do
      is_expected.to render_template('hearings/_court_applications_v2')
    end
  end
end
