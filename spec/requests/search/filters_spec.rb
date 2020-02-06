# frozen_string_literal: true

RSpec.describe 'search', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'when choosing search filters', type: :request do
    before { get '/search_filters/new' }

    it 'renders search_filters#new' do
      expect(response).to render_template('search_filters/new')
    end
  end
end
