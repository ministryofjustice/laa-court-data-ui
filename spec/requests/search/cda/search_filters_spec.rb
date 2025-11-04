# frozen_string_literal: true

RSpec.describe 'Search filters', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe '#new' do
    before { get '/search_filters/new' }

    it 'renders search_filters#new' do
      expect(response.body).to include('/search_filters')
    end
  end

  describe '#create' do
    before { post '/search_filters', params: }

    context 'when posting a valid search filter' do
      let(:params) { { search_filter: { id: 'whatever' } } }
      let(:target_path) { new_search_path(params: { search: { filter: 'whatever' } }) }

      before { post '/search_filters', params: }

      it { expect(response).to redirect_to(target_path) }
    end

    context 'when posting a invalid search filter' do
      let(:params) { { search_filter: { id: nil } } }

      before { post '/search_filters', params: }

      it { expect(response.body).to include('There is a problem') }
    end
  end
end
