# frozen_string_literal: true

RSpec.describe 'hearings_v2', type: :request do
  let(:user) { create(:user) }
  let(:hearing_id) { '345be88a-31cf-4a30-9de3-da98e973367e' }
  let(:case_reference) { 'TEST12345' }

  context 'when authenticated', :stub_v2_hearing_summary, :stub_v2_hearing_data, :stub_v2_hearing_events,
          :stub_case_search do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'shows renders the hearing page' do
      expect(response).to render_template('hearings/show')
    end

    it 'shows the hearing table' do
      expect(response).to render_template(:_hearing_events)
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

  context 'when no hearing data available', :stub_v2_hearing_summary, :stub_v2_no_hearing_data,
          :stub_v2_hearing_events, :stub_case_search do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'shows renders the hearing page' do
      expect(response).to render_template('hearings/show')
    end

    it 'shows v2 hearing table' do
      expect(response).to render_template(:_hearing_events)
    end
  end

  context 'when server error occurs on hearing results', :stub_v2_hearing_summary,
          :stub_v2_hearing_data_error, :stub_case_search do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'redirects back to prosecution case page' do
      expect(response).to redirect_to prosecution_case_path(case_reference)
    end

    it 'flashes notice' do
      expect(flash.now[:alert]).to match(/Error retrieving data from server/)
    end
  end

  context 'when server error occurs on hearing summary', :stub_v2_hearing_summary_error,
          :stub_v2_hearing_data, :stub_case_search do
    before do
      sign_in user
      get "/hearings/#{hearing_id}?page=0&urn=#{case_reference}"
    end

    it 'redirects back to prosecution case page' do
      expect(response).to redirect_to prosecution_case_path(case_reference)
    end

    it 'flashes notice' do
      expect(flash.now[:alert]).to match(/Error retrieving data from server/)
    end
  end
end
