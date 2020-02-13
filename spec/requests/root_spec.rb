# frozen_string_literal: true

RSpec.describe 'Root route', type: :request do
  context 'without sign in' do
    before { get '/' }

    it 'redirects to devise/sessions/new' do
      expect(response).to render_template('devise/sessions/new')
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

  context 'when page loads' do
    before { get '/' }

    it 'loads google analytics' do
      expect(response).to render_template('layouts/_google_analytics')
    end
  end
end
