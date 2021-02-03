# frozen_string_literal: true

RSpec.describe 'hearings/_listing_info.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'listing_info', locals: { hearing: decorated_hearing, hearing_day: hearing_day }
  end

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
  let(:decorated_hearing) { view.decorate(hearing) }
  let(:hearing_day) { Date.parse('2021-01-17T10:30:00.000Z') }

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
