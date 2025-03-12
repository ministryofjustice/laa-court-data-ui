# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cookie banner', type: :request do
  describe 'GET /update_cookies' do
    context 'when user accepts cookies' do
      before { get '/update_cookies', params: { cookies_preference: true } }

      it 'returns HTTP success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets analytics_cookies_set to true' do
        expect(response.header['Set-Cookie']).to include(/analytics_cookies_set=true/)
      end

      it 'sets cookies_preferences_set to true' do
        expect(response.header['Set-Cookie']).to include(/cookies_preferences_set=true/)
      end
    end

    context 'when user rejects cookies' do
      before { get '/update_cookies', params: { cookies_preference: false } }

      it 'returns HTTP success' do
        expect(response).to have_http_status(:success)
      end

      it 'sets analytics_cookies_set to true' do
        expect(response.header['Set-Cookie']).to include(/analytics_cookies_set=false/)
      end

      it 'sets cookies_preferences_set to true' do
        expect(response.header['Set-Cookie']).to include(/cookies_preferences_set=true/)
      end
    end

    context 'when hiding banner' do
      before { get '/update_cookies', params: { hide_banner: true } }

      it 'responds with empty turbo frame' do
        expect(response.body).to eq empty_turbo_frame
      end
    end
  end

  def empty_turbo_frame
    "<turbo-frame id='removable'></turbo-frame>\n"
  end
end
