# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cookies', type: :request do
  describe 'GET /cookies/settings' do
    before { get '/cookies/settings', params: {}, headers: { HTTP_REFERER: '/' } }

    it 'returns HTTP success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @cookie' do
      expect(assigns(:cookie)).to be_instance_of(Cookie)
    end

    it 'renders the template' do
      expect(response).to render_template(:new)
    end

    it 'stores the request referrer' do
      expect(session[:return_to]).to eq '/'
    end

    context 'when requests referrer is /searches endpoint' do
      before { get '/cookies/settings', params: {}, headers: { HTTP_REFERER: '/searches' } }

      it 'stores the request referrer' do
        expect(session[:return_to]).to eq '/searches'
      end
    end

    it 'sets @cookie.analytics to analytics_cookies_set cookie value' do
      expect(assigns(:cookie).analytics.to_s).to eq cookies[:analytics_cookies_set]
    end
  end

  describe 'POST /cookies/settings' do
    context 'when cookies are valid' do
      before { post '/cookies/settings', params: { cookie: { analytics: true } } }

      it 'assigns @cookie' do
        expect(assigns(:cookie)).to be_instance_of(Cookie)
      end

      it 'redirects to cookies settings path' do
        expect(response).to redirect_to(cookies_settings_path)
      end

      it 'sets the flash message' do
        expect(flash[:success]).to include "You've set your cookie preferences."
      end

      it 'sets the analytics_cookies_set cookie' do
        expect(cookies[:analytics_cookies_set]).to eq 'true'
      end

      it 'sets cookies_preferences_set cookie to true' do
        expect(cookies[:cookies_preferences_set]).to eq 'true'
      end
    end

    context 'when cookies are invalid' do
      before { post '/cookies/settings', params: { cookies: { analytics: nil } } }

      it 'assigns @cookie' do
        expect(assigns(:cookie)).to be_instance_of(Cookie)
      end

      it 'renders the template' do
        expect(response).to render_template(:new)
      end

      it 'sets error message' do
        expect(assigns(:cookie).errors[:analytics][0]).to eq "can't be blank"
      end
    end
  end

  describe 'GET /cookies' do
    it 'returns HTTP success' do
      get '/cookies'

      expect(response).to have_http_status(:success)
    end
  end
end
