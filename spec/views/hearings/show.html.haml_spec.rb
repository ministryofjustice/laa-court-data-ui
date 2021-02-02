# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view do
  subject(:render_view) { render }

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A heading'
    assign(:hearing, hearing)
    allow(hearing).to receive(:hearing_events).and_return([])
  end

  it { is_expected.to render_template(:_attendees) }
  it { is_expected.to render_template(:_hearing_events) }

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

    it { is_expected.to have_selector('th.govuk-table__header', text: /Result/) }
    it { is_expected.to have_selector('td.govuk-table__cell', text: /Ineffective: Another case over-ran/) }
  end

  context 'without cracked_ineffective_trial' do
    let(:cracked_ineffective_trial) { nil }

    before do
      allow(hearing)
        .to receive(:cracked_ineffective_trial)
        .and_return(cracked_ineffective_trial)
    end

    it { is_expected.not_to have_selector('th.govuk-table__header', text: /Result/) }
  end
end
