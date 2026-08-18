# frozen_string_literal: true

RSpec.describe "link migrated case maat reference", :vcr, type: :request do
  let(:user) { create(:user) }

  let(:link_migrated_case_id_from_fixture) { "97140ef9-3a85-4d9a-89b0-eccca35486a1" }
  let(:id) { link_migrated_case_id_from_fixture }
  let(:link_migrated_case) { build(:link_migrated_case, :action_required, id:) }
  let(:case_urn) { "TEST12345" }
  let(:defendant_id) { defendant_id_from_fixture }
  let(:defendant_id_from_fixture) { "353d829f-a3e6-425e-b325-f6f13c059f0b" }

  let(:maat_reference) { "1234567" }

  let(:params) do
    {
      urn: case_urn,
      maat_ref_required: "true",
      link_attempt: { maat_reference: },
    }
  end

  let(:api_request_path) { %r{.*/laa_references} }

  let(:expected_request_payload) do
    {
      laa_reference: {
        defendant_id:,
        user_name: user.username,
        maat_reference:,
      },
    }
  end

  context "when authenticated" do
    before do
      sign_in user
      post "/link_migrated_cases/#{id}/link", params:
    end

    context "with valid params", :stub_v2_link_success do
      it "sends a link request to the adapter" do
        expect(a_request(:post, api_request_path)
          .with(body: expected_request_payload.to_json))
          .to have_been_made.once
      end

      it "returns status 302" do
        expect(response).to have_http_status :redirect
      end

      it "redirects to back to the link migrated case path" do
        expect(response).to redirect_to link_link_migrated_case_path(id:)
      end

      it "flashes success banner" do
        expect(flash.now[:success_moj_banner]).to eq("Case linked successfully.")
      end
    end

    context "when defendant_id is not a valid uuid", :stub_v2_link_failure_with_invalid_defendant_uuid do
      it {
        expect(response.body).to include "The MAAT reference you provided is not available to " \
                                         "be associated with this defendant."
      }

      it { expect(response.body).to include("Link court data") }
    end

    context "with invalid maat_reference" do
      context "when MAAT API does not know maat reference",
              :stub_v2_link_failure_with_unknown_maat_reference do
        it {
          expect(response.body).to include "The MAAT reference you provided is not available to " \
                                           "be associated with this defendant."
        }

        it { expect(response.body).to include("Link court data") }
      end

      context "when invalid format" do
        let(:maat_reference) { "A2123456" }

        it "displays error summary with invalid error" do
          expect(response.body).to include("Enter a MAAT ID in the correct format")
        end

        it "renders the link page" do
          expect(response.body).to include("Link court data")
        end
      end
    end

    context "when server returns 500 error", :stub_v2_link_server_failure do
      it { expect(response.body).to include "Court Data Adaptor could not be reached." }
    end

    context "when cda returns 424 error", :stub_v2_link_cda_failure do
      it { expect(response.body).to include "HMCTS Common Platform could not be reached." }

      it { expect(response.body).to include "Create link without MAAT ID" }
    end
  end

  context "when not authenticated" do
    context "when creating a reference" do
      before { post "/link_migrated_cases/#{id}/link", params: }

      it_behaves_like "unauthenticated request"
    end
  end
end
