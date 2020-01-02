require "rails_helper"

RSpec.describe "Search by case", :type => :request do
  it 'renders search#new' do
    get '/'
    expect(response).to render_template('search/new')

    post '/search', params: { query: 'T20200001' }
    expect(response).to have_http_status 200
  end
end
