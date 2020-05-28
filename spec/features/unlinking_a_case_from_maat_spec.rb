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
        let(:stub) do
          json_api_data = {
            data: [{
              attributes: {
                user_name: user.email,
                unlink_reason_code: '',
                unlink_reason_text: 'unknown'
              }
            }]
          }

          stub_request(:patch, "#{api_url}/defendants/#{defendant_asn}")
            .with(body: json_api_data.to_json)
        end

        it 'does not show the option to link to a MAAT ID' do
          stub
          expect(page).not_to have_content('Enter the MAAT ID')
        end

        it 'sends an unlink request to the adapter when I choose to unlink' do
          click_on 'Remove link to court data'
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
