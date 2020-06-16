# frozen_string_literal: true

RSpec.describe 'Unlinking a defendant from MAAT', type: :feature do
  let(:defendant_asn) { '0TSQT1LMI7CR' }
  let(:api_url) { ENV['COURT_DATA_ADAPTOR_API_URL'] }

  context 'when viewing defendant details' do
    let(:user) { create(:user) }

    before do
      sign_in user
      query = hash_including({ filter: { arrest_summons_number: defendant_asn } })
      body = load_json_stub(defendant_fixture)
      json_api_header = { 'Content-Type' => 'application/vnd.api+json' }

      stub_request(:get, "#{api_url}/prosecution_cases")
        .with(query: query)
        .to_return(body: body, headers: json_api_header)

      visit "defendants/#{defendant_asn}"
    end

    context 'with unlinked defendant' do
      let(:defendant_fixture) { 'unlinked/defendant_by_reference_body.json' }

      it 'asks the user to link to a MAAT ID' do
        expect(page).to have_content('Enter the MAAT ID')
      end
    end

    context 'with linked defendant' do
      let(:defendant_fixture) { 'linked/defendant_by_reference_body.json' }

      it 'does not display the link to a MAAT ID field' do
        expect(page).not_to have_field('MAAT ID')
        expect(page).not_to have_content('Enter the MAAT ID')
      end

      it 'displays the remove MAAT ID link' do
        expect(page).to have_link('Remove link to court data')
        expect(page).to have_govuk_warning('Removing the link will stop hearing updates being received')
      end

      context 'when unlinking the defendant' do
        let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
        let(:path) { "#{api_url}/defendants/#{defendant_id_from_fixture}" }
        let(:payload) do
          {
            data:
            {
              id: defendant_id_from_fixture,
              type: 'defendants',
              attributes: {
                prosecution_case_reference: 'TEST12345',
                user_name: user.username,
                unlink_reason_code: 1,
                unlink_reason_text: 'Wrong MAAT ID'
              }
            }
          }
        end

        before do
          stub_request(:patch, path)
          click_on 'Remove link to court data'
        end

        # TODO: this is more of a request spec and should be moved there
        it 'sends an unlink request to the adapter' do
          expect(a_request(:patch, path)
            .with(body: payload.to_json))
            .to have_been_made
        end

        it 'displays flash notice' do
          expect(page).to \
            have_govuk_flash(:notice, text: 'You have successfully unlinked from the court data source')
        end
      end
    end
  end
end
