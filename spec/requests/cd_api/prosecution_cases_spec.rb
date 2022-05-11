# frozen_string_literal: true

RSpec.describe 'prosecution cases', type: :request, stub_case_search: true,
                                    stub_hearing_summaries_v2: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'THISISSTUBBED' }

  context 'when authenticated' do
    before do
      sign_in user
      allow(Feature).to receive(:enabled?).with(:hearing_summaries).and_return(true)
      allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(false)
      get "/prosecution_cases/#{case_urn}"
    end

    it 'renders prosecution_cases/show' do
      expect(response).to render_template('prosecution_cases/show')
    end

    context 'when defendants_search flag is on', stub_defendants_case_search: true do
      before { allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(true) }

      it 'renders prosecution_cases/show' do
        expect(response).to render_template('prosecution_cases/show')
      end

      context 'when exception ActiveResource::BadRequest is raised' do
        before do
          allow(CdApi::CaseSummary).to receive(:find).and_raise(ActiveResource::BadRequest, 'Fake error')
          get "/prosecution_cases/#{case_urn}"
        end

        let(:search_params) do
          { search: { term: case_urn, filter: :case_reference } }
        end

        it 'redirects to the searches page' do
          expect(response).to redirect_to(searches_path(search_params))
        end
      end

      context 'when exception ActiveResource::ServerError is raised' do
        before do
          allow(CdApi::CaseSummary).to receive(:find).and_raise(ActiveResource::ServerError, 'Fake error')
        end

        let(:search_params) do
          { search: { term: case_urn, filter: :case_reference } }
        end

        it 'redirects to the searches page' do
          get "/prosecution_cases/#{case_urn}"
          expect(response).to redirect_to(searches_path(search_params))
        end

        it 'captures the exception in Sentry' do
          allow(Sentry).to receive(:capture_exception).with(ActiveResource::ServerError)
          get "/prosecution_cases/#{case_urn}"
          expect(Sentry).to have_received(:capture_exception)
        end
      end
    end
  end

  context 'when not authenticated' do
    before do
      get "/prosecution_cases/#{case_urn}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
