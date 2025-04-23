# frozen_string_literal: true

RSpec.describe 'hearings/show', :stub_v2_hearing_data, :stub_v2_hearing_summary, type: :view do
  subject(:render_view) { render }

  let(:case_reference) { 'TEST12345' }
  let(:prosecution_case) do
    build(:case_summary, :with_hearing_summaries,
          prosecution_case_reference: case_reference)
  end
  let(:decorated_prosecution_case) { view.decorate(prosecution_case, CdApi::CaseSummaryDecorator) }
  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing_events) do
    CdApi::HearingEvents.find(hearing_id,
                              params: { date: hearing_day.strftime('%F') })
  end
  let(:hearing) do
    view.decorate(CdApi::Hearing.find(hearing_id,
                                      params: { date: hearing_day.strftime('%F') }), CdApi::HearingDecorator)
  end
  let(:paginator) do
    HearingPaginator.new(decorated_prosecution_case, column: 'date', direction: 'asc', page: '0')
  end

  before do
    allow(view).to receive(:govuk_page_title).and_return 'Hearings Page'

    assign(:hearing, hearing)
    assign(:hearing_day, hearing_day)
    assign(:paginator, paginator)
    assign(:prosecution_case, decorated_prosecution_case)
  end

  context 'when viewing hearing details' do
    it 'displays the partial' do
      is_expected.to render_template('hearings/_details')
    end
  end

  context 'when viewing attendees' do
    it 'displays the partial' do
      is_expected.to render_template('hearings/_attendees')
    end
  end

  context 'when viewing results' do
    it 'displays the partial' do
      is_expected.to render_template('hearings/_hearing_result')
    end
  end

  context 'when viewing court applications' do
    it 'displays the partial' do
      is_expected.to render_template('hearings/_court_applications')
    end
  end
end
