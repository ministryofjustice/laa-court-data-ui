require "pact/rspec"

RSpec.describe "linking defendant", :pact, :stub_unlinked, type: :request do
  include_context "with laa-court-data-adaptor consumer pact"

  let(:user) { create(:user, username: "test_user") }

  let(:case_urn) { "TEST12345" }
  let(:maat_reference) { "1234567" }
  let(:defendant_id) { defendant_id_from_fixture }
  let(:defendant_id_from_fixture) { "41fcb1cd-516e-438e-887a-5987d92ef90f" }

  let(:params) do
    { urn: case_urn,
      link_attempt: { maat_reference: },
      maat_ref_required: true }
  end

  before do
    sign_in user
  end

  around do |example|
    VCR.turned_off { example.run }
  end

  context "when an error occurs in the CDA API" do
    {
      "a MAAT ID that is already linked" => "maat_reference_already_linked_contract_failure",
      "an invalid MAAT ID" => "maat_reference_invalid_contract_failure",
      "a MAAT ID with no Common Platform data" => "maat_reference_no_common_platform_data_contract_failure",
    }.each do |scenario, error|
      context "with #{scenario}" do
        let(:body) do
          {
            laa_reference: {
              defendant_id: match_uuid(defendant_id),
              maat_reference: match_regex(/\A[0-9]{7}\z/, maat_reference),
              user_name: match_any_string(user.username),
            },
          }
        end

        let(:interaction) do
          new_interaction
            .given(scenario)
            .upon_receiving("a request to link a defendant")
            .with_request(
              method: :post,
              path: "/api/internal/v2/laa_references/",
              body:,
              headers: {
                "Authorization" => match_any_string(Cda::Client.instance.bearer_token),
              },
            )
            .will_respond_with(status: 422, body: { error_codes: [error] }, headers: { "Content-Type" => "application/vnd.api+json; charset=utf-8" })
        end

        it "shows the correct error message for #{scenario}" do
          interaction.execute do |mock_server|
            Cda::ProsecutionCaseLaaReference.site = mock_server.url
            post "/defendants/#{defendant_id}/link", params: params

            expect(response.body).to include(I18n.t("cda_errors.#{error}"))
          end
        end
      end
    end
  end
end
