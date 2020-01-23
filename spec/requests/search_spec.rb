# frozen_string_literal: true

RSpec.describe 'search', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'Choose search filters', type: :request do
    it 'renders search_filters#new' do
      get '/search_filters/new'
      expect(response).to render_template('search_filters/new')
    end
  end

  describe 'Search by case', type: :request do
    it 'renders searches#new' do
      get '/searches/new', params: { search: { filter: :case_number } }
      expect(response).to render_template('searches/new')
    end

    it 'accepts query paramater' do
      post '/searches', params: { search: { query: 'T20200001', filter: :case_number } }
      expect(response).to have_http_status :ok
    end
  end

  describe 'no result', type: :request do
    before do
      allow_any_instance_of(Search).to receive(:execute).and_return([])
    end

    it 'renders searches/_no_results template' do
      post '/searches', params: { search: { query: 'T20200001', filter: :case_number } }
      expect(response).to render_template('searches/_no_results')
    end
  end
end
