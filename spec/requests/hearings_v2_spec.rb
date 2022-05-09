# frozen_string_literal: true

RSpec.describe 'hearings_v2', type: :request do
  let(:user) { create(:user) }
  let(:hearing_id) { '345be88a-31cf-4a30-9de3-da98e973367e' }
  let(:case_reference) { 'TEST12345' }

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_search).and_return(false)
    allow(Feature).to receive(:enabled?).with(:hearing).and_return(true)
  end

  context 'when authenticated', stub_v2_hearing_summary: true, stub_v2_hearing_data: true,
                                stub_v2_hearing_events: true, stub_case_search: true do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    context 'when v2 is enabled' do
      it 'shows renders the hearing page' do
        expect(response).to render_template('hearings/show')
      end

      it 'shows v2 hearing table' do
        expect(response).to render_template(:_hearing_events_v2)
      end
    end
  end

  context 'when not authenticated' do
    before do
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'redirects to sign in page' do
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'when no hearing data available', stub_v2_hearing_summary: true, stub_v2_no_hearing_data: true,
                                            stub_case_search: true do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'redirects back to prosecution case page' do
      expect(response).to redirect_to prosecution_case_path(case_reference)
    end

    it 'flashes notice' do
      expect(flash.now[:notice]).to match(/No hearing details available/)
    end
  end

  context 'when server error occurs', stub_v2_hearing_summary: true, stub_v2_hearing_data_error: true,
                                      stub_case_search: true do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'redirects back to prosecution case page' do
      expect(response).to redirect_to prosecution_case_path(case_reference)
    end

    it 'flashes notice' do
      expect(flash.now[:notice]).to match(/Error retrieving data from server/)
    end
  end
end
