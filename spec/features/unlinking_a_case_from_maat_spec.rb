# frozen_string_literal: true

describe 'unlinking a case from MAAT', type: :feature do
  let(:defendant_asn) { '0TSQT1LMI7CR' }
  let(:api_url) { ENV['COURT_DATA_ADAPTOR_API_URL'] }

  context 'when signed in' do
    let(:user) { create(:user) }

    before { sign_in user }

    describe 'viewing a case' do
      before do
        query = hash_including({ filter: { arrest_summons_number: defendant_asn } })
        body = load_json_stub(defendant_fixture)
        json_api_header = { 'Content-Type' => 'application/vnd.api+json' }

        stub_request(:get, "#{api_url}/prosecution_cases")
          .with(query: query)
          .to_return(body: body, headers: json_api_header)

        visit "defendants/#{defendant_asn}"
      end

      context 'with no link' do
        let(:defendant_fixture) { 'unlinked/defendant_by_reference_body.json' }

        it 'asks the user to link to a MAAT ID' do
          expect(page).to have_content('Enter the MAAT ID')
        end
      end

      context 'with a pre-existing link' do
        let(:defendant_fixture) { 'linked/defendant_by_reference_body.json' }
        let(:defendant_id_from_fixture) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
        let(:path) { "#{api_url}/defendants/#{defendant_id_from_fixture}" }

        before { stub_request(:patch, path) }

        it 'does not show the option to link to a MAAT ID' do
          expect(page).not_to have_content('Enter the MAAT ID')
        end

        it 'sends an unlink request to the adapter when I choose to unlink' do
          click_on 'Remove link to court data'

          expected_data = {
            data:
            {
              id: defendant_id_from_fixture,
              type: 'defendants',
              attributes: {
                prosecution_case_reference: 'TEST12345',
                user_name: 'example',
                unlink_reason_code: 1,
                unlink_reason_text: 'Wrong MAAT ID'
              }
            }
          }

          expect(a_request(:patch, path)
            .with { |req| req.body == expected_data.to_json })
            .to have_been_made
        end
      end
    end
  end
end
