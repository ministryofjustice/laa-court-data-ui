# frozen_string_literal: true

RSpec.describe 'error routes', type: :request do
  describe 'GET #not_found', type: :request do
    before { get '/not-exists' }

    it 'has a status of 404' do
      expect(response.status).to eq(404)
    end

    it 'renders the 404/not_found template' do
      expect(response).to render_template('errors/not_found')
    end
  end

  describe 'GET #unacceptable', type: :request do
    before { get '/422' }

    it 'has a status of 422' do
      expect(response.status).to eq(422)
    end

    it 'renders the 422/unacceptable template' do
      expect(response).to render_template('errors/unacceptable')
    end
  end

  describe 'GET #internal_error', type: :request do
    before { get '/500' }

    it 'has a status of 500' do
      expect(response.status).to eq(500)
    end

    it 'renders the 500/internal_error template' do
      expect(response).to render_template('errors/internal_error')
    end
  end
end
