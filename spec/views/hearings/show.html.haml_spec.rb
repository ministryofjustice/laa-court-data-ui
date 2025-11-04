# frozen_string_literal: true

RSpec.describe 'hearings/show', :stub_v2_hearing_data, :stub_v2_hearing_summary, type: :view do
  subject(:render_view) { render }

  let(:case_reference) { 'TEST12345' }
  let(:prosecution_case) do
    build(:prosecution_case, :with_hearing_summaries,
          prosecution_case_reference: case_reference)
  end
  let(:decorated_prosecution_case) { view.decorate(prosecution_case, Cda::CaseSummaryDecorator) }
  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing_events) do
    Cda::HearingEventLog.find_from_hearing_and_date(hearing_id, date: hearing_day.strftime('%F'))
  end
  let(:hearing) do
    view.decorate(Cda::Hearing.find(hearing_id), Cda::HearingDecorator)
  end
  let(:paginator) do
    HearingPaginator.new(decorated_prosecution_case, hearing_id:, hearing_day: Date.new(2021, 1, 19))
  end

  before do
    allow(view).to receive(:govuk_page_heading).and_return 'Hearings Page'

    assign(:hearing, hearing)
    assign(:hearing_day, hearing_day)
    assign(:paginator, paginator)
    assign(:prosecution_case, decorated_prosecution_case)
  end

  context 'when viewing hearing details' do
    it 'displays the partial' do
      is_expected.to include('Hearings Page')
    end
  end

  context 'when viewing results' do
    it 'displays the partial' do
      is_expected.to include('Attendees')
    end
  end

  context 'when viewing court applications' do
    it 'displays the partial' do
      is_expected.to include('Court Applications')
    end
  end
end
