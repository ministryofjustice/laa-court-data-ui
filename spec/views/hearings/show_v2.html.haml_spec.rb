# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view, stub_v2_hearing_data: true,
                                          stub_v2_hearing_summary: true do
  subject(:render_view) { render }

  let(:case_reference) { 'TEST12345' }
  let(:prosecution_case) { view.decorate(CdApi::CaseSummary.find(case_reference)) }
  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing_events) do
    CdApi::HearingEvents.find(hearing_id,
                              params: { date: hearing_day.strftime('%F') })
  end
  let(:hearing) do
    CdApi::Hearing.find(hearing_id,
                        params: { date: hearing_day.strftime('%F') })
  end
  let(:paginator) do
    HearingPaginator.new(prosecution_case, column: 'date', direction: 'asc', page: '0')
  end

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(false)
    allow(Feature).to receive(:enabled?).with(:hearing).and_return(true)

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
