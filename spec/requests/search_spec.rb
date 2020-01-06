# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search', type: :request do
  describe 'Choose search options', type: :request do
    it 'renders search#new' do
      get '/search/new'
      expect(response).to render_template('search/new')
    end
  end

  describe 'Search by case', type: :request do
    it 'renders search#index' do
      get '/search'
      expect(response).to render_template('search/index')
    end

    it 'accepts query paramater' do
      post '/search', params: { query: 'T20200001' }
      expect(response).to have_http_status :ok
    end
  end
end
