# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /accessibility' do
    before { get '/accessibility' }

    it 'returns HTTP success' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the accessibility statement heading' do
      expect(response.body).to include('Accessibility Statement')
    end
  end
end
