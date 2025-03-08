# frozen_string_literal: true

RSpec.describe 'Search filters', type: :request do
  let(:user) { create(:user) }

  before do
    allow(FeatureFlag).to receive(:enabled?).with(:defendants_search).and_return(true)
    sign_in user
  end

  describe '#new' do
    before { get '/search_filters/new' }

    it 'renders search_filters#new' do
      expect(response).to render_template('search_filters/new')
    end
  end

  describe '#create' do
    before { post '/search_filters', params: }

    context 'when posting a valid search filter' do
      let(:params) { { search_filter: { id: 'whatever' } } }
      let(:target_path) { new_search_path(params: { search: { filter: 'whatever' } }) }

      it { expect(response).to redirect_to(target_path) }
    end

    context 'when posting a invalid search filter' do
      let(:params) { { search_filter: { id: nil } } }

      it { expect(response).to render_template(:new) }
    end
  end
end
