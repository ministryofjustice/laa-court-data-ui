# frozen_string_literal: true

RSpec.describe "OAuth2::Error handling", type: :request do
  let(:user) { create(:user, roles: %w[caseworker]) }
  let(:oauth_response) { instance_double(OAuth2::Response, status: 401) }
  let(:oauth_error) do
    OAuth2::Error.allocate.tap do |e|
      e.instance_variable_set(:@response, oauth_response)
      e.instance_variable_set(:@code, "invalid_client")
      e.instance_variable_set(:@description, "The client credentials are invalid")
    end
  end

  let(:log_events) { [] }

  before do
    allow(Sentry).to receive(:capture_exception)
    allow(Cda::Client.instance).to receive(:bearer_token).and_raise(oauth_error)

    sign_in user

    log_events.concat(
      capture_semantic_logger_events do
        post "/searches", params: { search: { term: "MOGUERBXIZ", filter: :case_reference } }
      end,
    )
  end

  it "logs a clean message without the response body" do
    expect(log_events).to include(
      a_semantic_logger_event(
        level: :error,
        message_includes: "status=401 invalid_client The client credentials are invalid",
      ),
    )
  end

  it "sends Sentry a RuntimeError with the clean message" do
    expect(Sentry).to have_received(:capture_exception)
      .with(have_attributes(class: RuntimeError,
                            message: "OAuth2::Error: status=401 invalid_client " \
                                     "The client credentials are invalid"))
  end

  it "redirects to the internal error page" do
    expect(response).to redirect_to("/500")
  end
end
