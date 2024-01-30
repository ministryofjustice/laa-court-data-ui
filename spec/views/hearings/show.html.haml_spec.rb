# frozen_string_literal: true

RSpec.describe 'hearings/show', type: :view do
  subject(:render_view) { render }

  # rubocop: disable RSpec/VerifiedDoubles
  # NOTE: an instance double would require more setup
  # and we are only testing partials are rendered.
  let(:prosecution_case) do
    double(ProsecutionCaseDecorator,
           hearings: [hearing],
           prosecution_case_reference: 'ACASEURN',
           sorted_hearings_with_day: [hearing],
           hearings_sort_column: 'date',
           hearings_sort_direction: 'asc')
  end
  # rubocop: enable RSpec/VerifiedDoubles

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new(hearing_events: []) }
  let(:decorated_hearing) { view.decorate(hearing) }
  let(:hearing_day) { Date.parse('2021-01-17T10:30:00.000Z') }
  let(:paginator) do
    HearingPaginator.new(prosecution_case, column: 'date', direction: 'asc', page: '0')
  end

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A Gov uk page title'
    allow(prosecution_case).to receive(:hearings_sort_column=)
    allow(prosecution_case).to receive(:hearings_sort_direction=)
    assign(:hearing, decorated_hearing)
    assign(:hearing_day, hearing_day)
    assign(:paginator, paginator)
  end

  it { is_expected.to have_content('A Gov uk page title') }
  it { is_expected.to render_template(:_pagination) }
  it { is_expected.to render_template(:_details) }
  it { is_expected.to render_template(:_attendees) }
  it { is_expected.to render_template(:_hearing_events) }
  it { is_expected.to render_template(:_court_applications) }

  context 'when hearing_events is missing' do
    let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }

    it { is_expected.not_to render_template(:_hearing_events) }
  end

  context 'with cracked_ineffective_trial' do
    let(:cracked_ineffective_trial) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'a-uuid',
             type: 'Ineffective',
             description: 'Another case over-ran')
    end

    before do
      allow(hearing)
        .to receive(:cracked_ineffective_trial)
        .and_return(cracked_ineffective_trial)
    end

    it { is_expected.to have_css('div.govuk-heading-s', text: /Result/) }
    it { is_expected.to have_css('p.govuk-body', text: /Ineffective: Another case over-ran/) }
  end

  context 'without cracked_ineffective_trial' do
    let(:cracked_ineffective_trial) { nil }

    before do
      allow(hearing)
        .to receive(:cracked_ineffective_trial)
        .and_return(cracked_ineffective_trial)
    end

    it { is_expected.to have_no_css('h2.govuk-heading-l', text: /Result/) }
  end
end
