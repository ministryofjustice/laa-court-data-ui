# frozen_string_literal: true

RSpec.describe 'prosecution_cases/cd_api/_hearing_summaries.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'prosecution_cases/cd_api/hearing_summaries',
           locals: { case_summary: decorated_case_summary, column: 'date',
                     direction: 'asc' }
  end

  let(:decorated_case_summary) { view.decorate(case_summary, CdApi::CaseSummaryDecorator) }
  let(:case_summary) { build(:case_summary, prosecution_case_reference: 'THECASEURN', hearing_summaries:) }

  let(:hearing_summaries) { [] }

  let(:hearing_summary) do
    build(:hearing_summary, id: 'hearing-uuid', hearing_type: 'First hearing', hearing_days: [hearing_day],
                            defence_counsels:)
  end

  let(:hearing_summary1) do
    build(:hearing_summary, id: 'hearing1-uuid', hearing_type: 'Trial', hearing_days: [hearing1_day],
                            defence_counsels:)
  end

  let(:hearing_summary2) do
    build(:hearing_summary, id: 'hearing2-uuid', hearing_type: 'Sentence', hearing_days: [hearing2_day],
                            defence_counsels:)
  end

  let(:hearing_day) { build(:hearing_day, sitting_day: '2021-01-17T10:30:00.000Z') }
  let(:hearing1_day) { build(:hearing_day, sitting_day: '2021-01-18T13:00:00.000Z') }
  let(:hearing2_day) { build(:hearing_day, sitting_day: '2021-01-19T15:19:15.000Z') }

  let(:defence_counsels) { [defence_counsel] }
  let(:defence_counsel) do
    build(:defence_counsel, first_name: 'Fred', last_name: 'Dibnah', status: 'QC', attendance_days:)
  end
  let(:attendance_days) { %w[2021-01-17 2021-01-18 2021-01-19] }

  before do
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
    allow(decorated_case_summary).to receive_messages(hearings_sort_column: 'date',
                                                      hearings_sort_direction: 'asc')
    render_partial
  end

  it { expect(rendered).to have_css('.govuk-heading-l', text: 'Hearings') }

  context 'with no hearing summaries' do
    let(:hearing_summaries) { [] }

    it 'does not render any rows' do
      expect(rendered).to have_no_css('tbody.govuk-table__body tr')
    end
  end

  context 'with many hearing summaries' do
    let(:hearing_summaries) { [hearing_summary, hearing_summary1, hearing_summary2] }

    context 'with single hearing day per hearing summary' do
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
      let(:hearing_day) { build(:hearing_day, sitting_day: '2021-01-17T13:30:15.000Z') }
      let(:hearing2_day) { build(:hearing_day, sitting_day: '2021-01-20T16:00:00.000Z') }

      let(:hearing1_day1) { build(:hearing_day, sitting_day: '2021-01-19T10:45:00.000Z') }
      let(:hearing1_day2) { build(:hearing_day, sitting_day: '2021-01-20T10:45:00.000Z') }
      let(:hearing_summary1) do
        build(:hearing_summary, id: 'hearing1-uuid', hearing_type: 'Trial',
                                hearing_days: [hearing1_day1, hearing1_day2], defence_counsels:)
      end

      it 'sorts hearings by hearing_days collection then by hearing day datetime' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: %r{17/01/2021.*First hearing}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: %r{19/01/2021.*Trial}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: %r{20/01/2021.*Trial}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(4)', text: %r{20/01/2021.*Sentence}m)
      end
    end

    context 'with estimated duration on multiday hearings' do
      let(:hearing_summaries) { [hearing_summary] }
      let(:hearing1_day1) { build(:hearing_day, sitting_day: '2021-01-19T10:45:00.000Z') }
      let(:hearing1_day2) { build(:hearing_day, sitting_day: '2021-01-20T10:45:00.000Z') }
      let(:hearing_summary) do
        build(:hearing_summary, id: 'hearing1-uuid', hearing_type: 'Trial',
                                hearing_days: [hearing1_day1, hearing1_day2], defence_counsels:)
      end

      it 'renders formated estimated duration on the first hearing day' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)',
                       text: %r{19/01/2021.*Trial\n\n\nEstimated duration 20 days}m)
          .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: %r{20/01/2021.*Trial}m)
      end

      it 'does not render duplicated estmated duration' do
        expect(rendered)
          .to have_no_css('tbody.govuk-table__body tr:nth-child(2)',
                          text: %r{20/01/2021.*Trial\n\n\nEstimated duration 20 days}m)
      end
    end

    context 'when defence counsel did not attend hearing day' do
      let(:attendance_days) { %w[2021-01-17 2021-01-19] }

      it 'renders provider list per row' do
        expect(rendered)
          .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: 'Fred Dibnah (QC)')
          .and have_css('tbody.govuk-table__body tr:nth-child(3)', text: 'Fred Dibnah (QC)')
      end

      it 'does not render provider for hearing day' do
        expect(rendered).to have_no_css('tbody.govuk-table__body tr:nth-child(2)',
                                        text: 'Fred Dibnah (QC)')
      end
    end
  end
end
