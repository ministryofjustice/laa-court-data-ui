# frozen_string_literal: true

RSpec.feature 'Viewing the hearings page', type: :feature, stub_case_search: true,
                                           stub_v2_hearing_events: true do
  let(:user) { create(:user) }
  let(:api_url_v2) { CdApi::BaseModel.site }
  let(:api_events_path) { "#{api_url_v2}hearing_events/#{hearing_id}?date=2019-10-23" }
  let(:api_data_path) { "#{api_url_v2}hearing/#{hearing_id}" }
  # let(:api_summary_path) { "#{api_url_v2}hearingsummaries/#{urn}" }
  let(:hearing_id) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(false)
    allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(false)
    allow(Feature).to receive(:enabled?).with(:hearing).and_return(true)

    sign_in user
    visit(url)
  end

  context 'when user views hearing page', stub_v2_hearing_data: true do
    let(:url) { "hearings/#{hearing_id}?column=date&direction=asc&page=0&urn=TEST12345" }

    it 'requests data for hearing events' do
      expect(a_request(:get, api_events_path)
        .with(query: { date: '2019-10-23' }))
        .to have_been_made.once
    end

    it 'requests data for hearing data' do
      expect(a_request(:get, api_data_path)
        .with(query: { date: '2019-10-23' }))
        .to have_been_made.once
    end

    it 'displays details section' do
      expect(page).to have_css('.govuk-heading-l', text: 'Details')
    end

    it 'displays attendees section' do
      expect(page).to have_css('.govuk-heading-l', text: 'Attendees')
    end

    it 'displays events section' do
      expect(page).to have_css('.govuk-heading-l', text: 'Events')
    end

    it 'displays court applications section' do
      expect(page).to have_css('.govuk-heading-l', text: 'Court Applications')
    end
  end
end
