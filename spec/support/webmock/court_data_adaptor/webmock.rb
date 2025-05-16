# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, :stub_oauth_token) do
    stub_request(:post, %r{http.*/oauth/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  config.before(:each, :stub_no_results) do
    stub_request(:get, %r{http.*/api/internal/v1/.*filter.*})
      .to_return(
        status: 200,
        body: '{ "data": [] }',
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
  end

  config.before(:each, :stub_case_search) do
    stub_request(
      :get, %r{http.*/v2/prosecution_cases\?filter.*}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )
  end

  config.before(:each, :stub_case_search_test12345) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[prosecution_case_reference\]=TEST12345&include=defendants,defendants.offences,hearing_summaries,hearings,hearings.hearing_events,hearings.providers}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked/prosecution_case_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_defendant_ref_search) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[(arrest_summons_number|national_insurance_number)\]=.*&include=defendants.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_defendant_name_search) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[date_of_birth\]=.*&filter\[name\]=.*&include=defendants.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_unlinked) do
    stub_request(
      :get, %r{http.*/v2/prosecution_cases\?filter.*}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )

    stub_request(
      :get,
      %r{http.*/api/internal/v1/defendants/#{defendant_id}\?include=offences}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked_defendant.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )

    stub_request(
      :get,
      %r{http.*/api/internal/v1/hearings/.*\?include=hearing_events,providers}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/vnd.api+json' },
      body: load_json_stub('hearing_by_id_body.json')
    )
  end

  config.before(:each, :stub_link_success) do
    stub_request(:post, %r{/api/internal/v1/laa_references}).to_return(status: 202, body: '')
  end

  config.before(:each, :stub_link_failure_with_invalid_defendant_uuid) do
    stub_request(
      :post, %r{/api/internal/v1/laa_references}
    ).to_return(
      status: 422,
      headers: { 'Content-Type' => 'application/vnd.api+json' },
      body: {
        'error' =>
          'Contract failed with: {:defendant_id=>[\"is not a valid uuid\"]},
          {:maat_reference=>[\"1234567 has no data created against Maat application.\"]}'
      }.to_json
    )
  end

  config.before(:each, :stub_link_failure_with_unknown_maat_reference) do
    stub_request(
      :post, %r{/api/internal/v1/laa_references}
    ).to_return(
      status: 422,
      headers: { 'Content-Type' => 'application/vnd.api+json' },
      body: { 'error' =>
                'Contract failed with: {:maat_reference=>' \
                '[\"1234567 has no common platform data created against Maat application.\"]' }.to_json
    )
  end

  config.before(:each, :stub_linked) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter.*arrest_summons_number.*#{defendant_asn}&include=defendants,defendants.offences}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )

    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter.*national_insurance_number.*#{defendant_nino}&include=defendants,defendants.offences}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_hearing) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/hearings/.*\?include=hearing_events,providers}
    ).to_return(
      status: 200,
      body: load_json_stub('hearing_by_id_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_hearing_no_providers) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/hearings/.*\?include=hearing_events,providers}
    ).to_return(
      status: 200,
      body: load_json_stub('hearing_by_id_no_providers_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, :stub_internal_v2_hearing_results) do
    stub_request(:get,
                 %r{http:.*/api/internal/v2/hearing_results/345be88a-31cf-4a30-9de3-da98e973367e})
      .to_return(
        status: 200,
        body: load_json_stub('cda/internal_v2_hearing_results_response.json')
      )
  end

  config.before(:each, :stub_internal_v2_hearing_not_found) do
    stub_request(:get,
                 %r{http:.*/api/internal/v2/hearing_results/345be88a-31cf-4a30-9de3-da98e973367e})
      .to_return(
        status: 404,
        body: {}.to_json
      )
  end

  config.before(:each, :stub_internal_v2_hearing_error) do
    stub_request(:get,
                 %r{http:.*/api/internal/v2/hearing_results/345be88a-31cf-4a30-9de3-da98e973367e})
      .to_return(
        status: 500,
        body: ''
      )
  end
end
