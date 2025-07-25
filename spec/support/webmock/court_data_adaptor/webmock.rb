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

  config.before(:each, :stub_case_search) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )
  end

  config.before(:each, :stub_unlinked) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )

    stub_request(
      :get,
      %r{http.*/api/internal/v2/prosecution_cases/.*/defendants/#{defendant_id}}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked_defendant.json'),
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

  config.before(:each, :stub_v2_link_success) do
    stub_request(:post, %r{/v2/laa_references}).to_return(status: 202, body: '')
  end

  config.before(:each, :stub_v2_link_failure_with_invalid_defendant_uuid) do
    stub_request(
      :post, %r{/v2/laa_references}
    ).to_return(
      status: 422,
      headers: { 'Content-Type' => 'application/json' },
      body: { 'errors' => {
                'defendant_id' => ['is not a valid uuid'],
                'maat_reference' => ['1234567 has no data created against Maat application.']
              },
              'error_codes' => ['maat_reference_contract_failure'] }.to_json
    )
  end

  config.before(:each, :stub_v2_link_failure_with_unknown_maat_reference) do
    stub_request(
      :post, %r{/v2/laa_references}
    ).to_return(
      status: 422,
      headers: { 'Content-Type' => 'application/json' },
      body: { 'errors' => { 'maat_reference' =>
                             ['1234567 has no common platform data created against Maat application.'] },
              'error_codes' => ['maat_reference_contract_failure'] }
              .to_json
    )
  end

  config.before(:each, :stub_v2_link_server_failure) do
    stub_request(
      :post, %r{/v2/laa_references}
    ).to_return(
      status: 500,
      body: ''
    )
  end

  config.before(:each, :stub_v2_link_cda_failure) do
    stub_request(
      :post, %r{/v2/laa_references}
    ).to_return(
      status: 424,
      body: '{ "error_codes": ["common_platform_connection_failed"] }'
    )
  end

  config.before(:each, :stub_defendants_case_search) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )
  end

  config.before(:each, :stub_defendants_ref_search) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )
  end

  config.before(:each, :stub_defendants_name_search) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/internal_v2_prosecution_cases_response.json')
    )
  end

  config.before(:each, :stub_no_v2_results) do
    stub_request(:get, %r{http.*/v2/defendants})
      .to_return(
        status: 200,
        body: '{ "defendant_summaries": [] }',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  config.before(:each, :stub_no_v2_case_results) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 200,
      body: '{ "total_results": 0, "results": [] }',
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  config.before(:each, :stub_defendants_failed_search) do
    stub_request(:get, %r{http.*/v2/defendants})
      .to_return(
        status: 400,
        body: '',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  config.before(:each, :stub_defendants_failed_case_search) do
    stub_request(
      :post, %r{http.*/v2/prosecution_cases}
    ).to_return(
      status: 400,
      headers: { 'Content-Type' => 'application/json' },
      body: ''
    )
  end

  config.before(:each, :stub_defendants_cda_failed) do
    stub_request(:post, %r{http.*/v2/prosecution_cases})
      .to_return(
        status: 500,
        body: '{ "error_codes": ["common_platform_connection_failed"] }',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  config.before(:each, :stub_unlink) do
    stub_request(
      :get,
      %r{http.*/api/internal/v2/prosecution_cases/.*/defendants/#{defendant_id}}
    ).to_return(
      status: 200,
      body: load_json_stub('linked_defendant.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )

    stub_request(
      :patch,
      %r{http.*/v2/laa_references/#{defendant_id}}
    ).to_return(
      status: 202,
      body: '',
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  config.before(:each, :stub_v2_unlink_bad_request) do
    stub_request(
      :patch, %r{/v2/laa_references/#{defendant_id}}
    ).to_return(
      status: 400,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        'error' => 'Contract error: {:user_name=>[\"must not exceed 10 characters\"]}',
        error_codes: ['user_name_contract_failure']
      }.to_json
    )
  end

  config.before(:each, :stub_v2_unlink_bad_response) do
    stub_request(
      :patch, %r{/v2/laa_references/#{defendant_id}}
    ).to_return(
      status: 422,
      headers: { 'Content-Type' => 'application/json' },
      body: { 'error' => "Contract error: {:user_name=>[\"must not exceed 10 characters\"]}",
              error_codes: ['user_name_contract_failure'] }.to_json
    )
  end

  config.before(:each, :stub_v2_unlink_server_failure) do
    stub_request(
      :patch, %r{/v2/laa_references/#{defendant_id}}
    ).to_return(
      status: 500,
      body: ''
    )
  end

  config.before(:each, :stub_v2_unlink_cda_failure) do
    stub_request(
      :patch, %r{/v2/laa_references/#{defendant_id}}
    ).to_return(
      status: 424,
      body: '{ "error_codes": ["common_platform_connection_failed"] }'
    )
  end

  config.before(:each, :stub_v2_hearing_events) do
    stub_request(
      :get, %r{/v2/hearings/#{hearing_id}/event_log/2019-10-23}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/hearing_events_response.json')
    )
  end

  config.before(:each, :stub_v2_hearing_events_empty) do
    stub_request(
      :get, %r{/v2/hearings/#{hearing_id}/event_log/2019-10-23}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/hearing_events_empty_response.json')
    )
  end

  config.before(:each, :stub_v2_hearing_events_not_found) do
    stub_request(
      :get, %r{/v2/hearings/#{hearing_id}/event_log/2019-10-23}
    ).to_return(
      status: 404
    )
  end

  config.before(:each, :stub_v2_hearing_events_error) do
    stub_request(
      :get, %r{/v2/hearings/#{hearing_id}/event_log/2019-10-23}
    ).to_return(
      status: 500
    )
  end

  config.before(:each, :stub_v2_hearing_summary_error) do
    stub_request(
      :get, %r{/v2/hearing_results/.*}
    ).to_return(
      status: 500,
      body: ''
    )
  end

  config.before(:each, :stub_v2_hearing_data) do
    stub_request(
      :get, %r{/v2/hearing_results/#{hearing_id}}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/hearing_data_response.json')
    )
  end

  config.before(:each, :stub_v2_empty_hearing_data) do
    stub_request(
      :get, %r{/v2/hearing_results/#{hearing_id}}
    ).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: load_json_stub('cda/hearing_data_empty_response.json')
    )
  end
end
