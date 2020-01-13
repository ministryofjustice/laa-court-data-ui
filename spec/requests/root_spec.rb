# frozen_string_literal: true

RSpec.describe 'Root route', type: :request do
  context 'without sign in' do
    before { get '/' }

    it 'redirects to users/sign_in' do
      expect(response).to redirect_to('/users/sign_in')
    end
  end

  context 'with sign in' do
    let(:user) { create(:user) }

    before do
      sign_in user
      get '/'
    end

    it 'renders search_filters/new' do
      expect(response).to render_template('search_filters/new')
    end
  end
end
