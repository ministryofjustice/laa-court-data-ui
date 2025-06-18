# frozen_string_literal: true

RSpec.feature 'Viewing the hearings page', :stub_case_search, :stub_v2_hearing_summary,
              :stub_internal_v2_hearing_results, type: :feature do
  let(:user) { create(:user) }
  let(:api_url_v2) { Cda::BaseModel.site }
  let(:api_events_path) { "#{api_url_v2}hearings/#{hearing_id}/event_log/2019-10-23" }
  let(:api_data_path) { "#{api_url_v2}hearing_results/#{hearing_id}" }
  let(:case_reference) { 'TEST12345' }
  let(:api_summary_path) { "#{api_url_v2}prosecution_cases//" }
  let(:hearing_id) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    sign_in user
    visit(url)
  end

  context 'when user views hearing page', :stub_v2_hearing_data do
    let(:url) { "hearings/#{hearing_id}?column=date&direction=asc&page=0&urn=#{case_reference}" }

    context 'with multiple defence counsels', :stub_v2_hearing_events do
      it 'displays details section' do
        expect(page).to have_text('Mark Jones (junior) for Leon Goodwin' \
                                  'David Williams (junior) for not available')
      end
    end

    context 'with multiple prosecution counsels', :stub_v2_hearing_events do
      it 'displays details section' do
        expect(page).to have_text('John Smith' \
                                  'Jane Doe')
      end
    end

    context 'with hearing events', :stub_v2_hearing_events do
      it 'requests data for hearing summary' do
        expect(a_request(:post,
                         api_summary_path)
            .with(body: { filter: { prosecution_case_reference: case_reference } }.to_json))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)).to have_been_made.once
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
        expect(a_request(:post,
                         api_summary_path)
            .with(body: { filter: { prosecution_case_reference: case_reference } }.to_json))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)).to have_been_made.once
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
        expect(a_request(:post,
                         api_summary_path)
                .with(body: { filter: { prosecution_case_reference: case_reference } }.to_json))
          .to have_been_made.once
      end

      it 'requests data for hearing events' do
        expect(a_request(:get, api_events_path))
          .to have_been_made.once
      end

      it 'requests data for hearing data' do
        expect(a_request(:get, api_data_path)).to have_been_made.once
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
