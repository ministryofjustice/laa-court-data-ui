# frozen_string_literal: true

require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, stub_oauth_token: true) do
    stub_request(:post, %r{http.*/oauth/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  config.before(:each, stub_no_results: true) do
    stub_request(:get, %r{http.*/api/internal/v1/.*filter.*})
      .to_return(
        status: 200,
        body: '{ "data": [] }',
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
  end

  config.before(:each, stub_case_search: true) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[prosecution_case_reference\]=.*&include=defendants,defendants.offences,hearing_summaries,hearings,hearings.hearing_events}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked/prosecution_case_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, stub_defendant_ref_search: true) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[(arrest_summons_number|national_insurance_number)\]=.*&include=defendants.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, stub_defendant_name_search: true) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[date_of_birth\]=.*&filter\[name\]=.*&include=defendants.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, stub_unlinked: true) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter\[prosecution_case_reference\]=#{case_urn}&include=defendants,defendants.offences,hearing_summaries,hearings,hearings.hearing_events}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked/prosecution_case_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )

    stub_request(
      :get,
      %r{http.*/api/internal/v1/defendants/#{defendant_id}}
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
      body: load_json_stub('hearing_by_id_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  config.before(:each, stub_link_success: true) do
    stub_request(:post, %r{/api/internal/v1/laa_references}).to_return(status: 202, body: '')
  end

  config.before(:each, stub_linked: true) do
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

  config.before(:each, stub_hearing: true) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/hearings/.*\?include=hearing_events,providers}
    ).to_return(
      status: 200,
      body: load_json_stub('hearing_by_id_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end
end
