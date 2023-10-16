# frozen_string_literal: true

RSpec.describe 'prosecution_cases/_hearing_summaries.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'hearing_summaries',
           locals: { prosecution_case: decorated_prosecution_case, column: 'date',
                     direction: 'asc' }
  end

  let(:decorated_prosecution_case) { view.decorate(prosecution_case) }
  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase.new(prosecution_case_reference: 'THECASEURN')
  end

  let(:hearings) { [] }
  let(:hearing) do
    CourtDataAdaptor::Resource::Hearing
      .new(id: 'hearing-uuid',
           hearing_type: 'First hearing',
           hearing_days:,
           providers:)
  end

  let(:hearing1) do
    CourtDataAdaptor::Resource::Hearing
      .new(id: 'hearing1-uuid',
           hearing_type: 'Trial',
           hearing_days: hearing1_days,
           providers:)
  end

  let(:hearing2) do
    CourtDataAdaptor::Resource::Hearing
      .new(id: 'hearing2-uuid',
           hearing_type: 'Sentence',
           hearing_days: hearing2_days,
           providers:)
  end

  let(:hearing_days) { ['2021-01-17T10:30:00.000Z'] }
  let(:hearing1_days) { ['2021-01-18T13:00:00.000Z'] }
  let(:hearing2_days) { ['2021-01-19T15:19:15.000Z'] }

  let(:providers) { [provider] }
  let(:provider) { CourtDataAdaptor::Resource::Provider.new(name: 'Fred Dibnah', role: 'QC') }

  before do
    allow(prosecution_case).to receive(:hearings).and_return(hearings)
    allow(decorated_prosecution_case).to receive_messages(hearings_sort_column: 'date',
                                                          hearings_sort_direction: 'asc')
    allow(hearing).to receive(:providers).and_return(providers)
    allow(hearing1).to receive(:providers).and_return(providers)
    allow(hearing2).to receive(:providers).and_return(providers)
    render_partial
  end

  it { expect(rendered).to have_css('.govuk-heading-l', text: 'Hearings') }

  context 'with no hearings' do
    let(:hearings) { [] }

    it 'does not render any rows' do
      expect(rendered).not_to have_css('tbody.govuk-table__body tr')
    end
  end

  context 'with many hearings' do
    let(:hearings) { [hearing, hearing1, hearing2] }

    context 'with single hearing day per hearing' do
      it 'renders a row per hearing' do
        expect(rendered).to have_css('tbody tr.govuk-table__row', count: 3)
      end

      it 'renders hearing type per row' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: 'First hearing')
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: 'Trial')
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: 'Sentence')
      end

      it 'renders link to hearing with urn' do
        expect(rendered).to have_link('17/01/2021', href: %r{hearings/.*\?.*urn=THECASEURN})
      end

      it 'renders link to hearing with page' do
        expect(rendered).to have_link('17/01/2021',
                                      href: %r{hearings/.*\?.*page=\d})
      end

      it 'sorts hearings by hearing day' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: '17/01/2021')
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: '18/01/2021')
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: '19/01/2021')
      end

      it 'renders provider list per row' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: 'Fred Dibnah (QC)')
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: 'Fred Dibnah (QC)')
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: 'Fred Dibnah (QC)')
      end
    end

    context 'with multiple hearing days per hearing' do
      let(:hearing_days) { ['2021-01-17T13:30:15.000Z'] }
      let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
      let(:hearing2_days) { ['2021-01-20T16:00:00.000Z'] }

      it 'sorts hearings by hearing_days collection then by hearing day datetime' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: %r{17/01/2021.*First hearing}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: %r{19/01/2021.*Trial}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: %r{20/01/2021.*Trial}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(4)', text: %r{20/01/2021.*Sentence}m)
      end
    end
  end
end
