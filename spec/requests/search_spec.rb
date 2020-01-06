# frozen_string_literal: true
require "rails_helper"

RSpec.describe 'Choose search scenario', type: :request do
  it 'renders search#new' do
    get '/search/new'
    expect(response).to render_template('search/new')
    expect(response).to have_http_status 200
  end
end

RSpec.describe 'Search by case', type: :request do
  it 'renders search#index' do
    get '/search'
    expect(response).to render_template('search/index')

    post '/search', params: { query: 'T20200001' }
    expect(response).to have_http_status 200
  end
end
