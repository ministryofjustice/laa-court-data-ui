# frozen_string_literal: true


RSpec.feature 'Viewing the hearings page',  :stub_cdapi_v2_hearing_summary2, type: :feature do # :stub_case_search,
  let(:user) { create(:user) }
  let(:api_url_v2) { CdApi::BaseModel.site }
  let(:api_events_path) { "#{api_url_v2}hearings/#{hearing_id}/hearing_events?date=2025-05-01" }

  # This one should use hearing_resoults from CDA
  let(:api_data_path) { "#{api_url_v2}hearings/#{hearing_id}" }

  let(:case_reference) { 'IGWTRAXVHK' }
  let(:api_summary_path) { "#{api_url_v2}case_summaries/#{case_reference}" }
  let(:hearing_id) { '8afd2757-efee-427a-a622-89c06d0f7320' }

  before do
    VCR.turn_off!

    dummy_token = instance_double('OAuth2::AccessToken', token: 'super-secret-key', expired?: false)
    allow(CourtDataAdaptor::OauthTokenProvider).to receive(:token).and_return(dummy_token)

    sign_in user
    visit(url)
  end

  after do
    VCR.turn_on!
  end

  context 'when user views hearing page', :stub_v2_hearing_data  do
    let(:url) { "hearings/#{hearing_id}?column=date&direction=asc&page=0&urn=#{case_reference}" }

    # context 'with multiple defence counsels', :stub_v2_hearing_events do
    context 'with multiple defence counsels', :stub_v2_hearing_events_2025_05_01 do
      it 'displays details section' do
        expect(page).to have_text('Felix McGlynn' \
                                  'Jeramy Sauer')
      end
    end

    context 'with multiple prosecution counsels', :stub_v2_hearing_events_2025_05_01 do
      it 'displays details section' do
        expect(page).to have_text('John Smith' \
                                  'Jane Doe')
      end
    end

    context 'with hearing events', :stub_v2_hearing_events_2025_05_01 do
      it 'requests data for hearing summary' do
        expect(a_request(:get, api_summary_path))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path)
                 .with(query: { date: '2025-05-01' }))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)
                 .with(query: { date: '2025-05-01' }))
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

    context 'with no hearing events', :stub_v2_hearing_events_not_found do
      it 'requests data for hearing summary' do
        expect(a_request(:get, api_summary_path))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path)
                 .with(query: { date: '2025-05-01' }))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)
                 .with(query: { date: '2025-05-01' }))
          .to have_been_made.once
      end

      it 'displays details section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Details')
      end

      context 'when raw response not displayed' do
        before do
          allow(Rails.configuration.x).to receive(:display_raw_responses).and_return(false)
        end

        it 'displays time listed' do
          expect(page).to have_text '08:30'
        end
      end

      it 'displays attendees section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Attendees')
      end

      it 'displays events section' do
        expect(page).to have_no_css('.govuk-heading-l', text: 'Events')
      end

      it 'displays court applications section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Court Applications')
      end
    end

    context 'with error fetching hearing events', :stub_v2_hearing_events_error do
      it 'requests data for hearing summary' do
        expect(a_request(:get, api_summary_path))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path)
                 .with(query: { date: '2025-05-01' }))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)
                 .with(query: { date: '2025-05-01' }))
          .to have_been_made.once
      end

      it 'displays details section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Details')
      end

      it 'displays attendees section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Attendees')
      end

      it 'displays events section' do
        expect(page).to have_no_css('.govuk-heading-l', text: 'Events')
      end

      it 'displays court applications section' do
        expect(page).to have_css('.govuk-heading-l', text: 'Court Applications')
      end

      it 'displays flash at top of page' do
        expect(page).to have_govuk_flash(:alert,
                                         text: 'There was an error retrieving the hearing ' \
                                               'events from the server')
      end
    end
  end
end
