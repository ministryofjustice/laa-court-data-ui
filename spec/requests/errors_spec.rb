# frozen_string_literal: true

RSpec.describe 'error routes', type: :request do
  describe 'GET #unauthorized', type: :request do
    before { get '/401' }

    it 'has a status of 401' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'renders the template' do
      expect(response.body).to include('Unauthorized connection to source data.')
    end
  end

  describe 'GET #not_found', type: :request do
    context 'with non-existent route' do
      before { get '/not-exists' }

      it 'has a status of 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'renders the 404/not_found template' do
        expect(response.body).to include('Page not found')
      end
    end

    context 'with non-existent route and format' do
      before { get '/.well-known/security.txt' }

      it 'has a status of 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'renders plain text' do
        expect(response.content_type).to include('text/plain')
      end

      it 'renders not found message' do
        expect(response.body).to include('Not found')
      end
    end
  end

  describe 'GET #unacceptable', type: :request do
    before { get '/422' }

    it 'has a status of 422' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'renders the 422/unacceptable template' do
      expect(response.body).to include('The change you wanted was rejected')
    end
  end

  describe 'GET #internal_error', type: :request do
    before { get '/500' }

    it 'has a status of 500' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the 500/internal_error template' do
      expect(response.body).to include('Sorry, something went wrong')
    end
  end
end
