# frozen_string_literal: true

RSpec.describe 'status', type: :request do
  describe 'get /ping' do
    context 'when environment variables not set' do
      before do
        ENV['APP_BRANCH'] = nil
        ENV['BUILD_DATE'] = nil
        ENV['BUILD_TAG']  = nil
        ENV['COMMIT_ID']  = nil

        get '/ping'
      end

      it 'returns a status of 200' do
        expect(response.status).to eq(200)
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values).to be_all('Not Available')
      end
    end

    context 'when environment variables set' do
      let(:expected_json) do
        {
          app_branch: 'feature_branch',
          build_date: '20150721',
          build_tag: 'test',
          commit_id: '123456'
        }.to_json
      end

      before do
        ENV['APP_BRANCH'] = 'feature_branch'
        ENV['BUILD_DATE'] = '20150721'
        ENV['BUILD_TAG']  = 'test'
        ENV['COMMIT_ID']  = '123456'

        get '/ping'
      end

      it 'returns a status of 200' do
        expect(response.status).to eq(200)
      end

      it 'returns JSON' do
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it 'returns JSON with app information' do
        expect(response.body).to eq(expected_json)
      end
    end
  end
end
