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
      get '/searches/new', params: { search: { filter: :prosecution_case_reference } }
      expect(response).to render_template('searches/new')
    end

    context 'when posting a query' do
      let(:client) { LAA::CourtDataAdaptor.client }
      let(:search_params) do
        { search: { query: '05PP1000915', filter: :prosecution_case_reference } }
      end

      it 'accepts query paramater' do
        post '/searches', params: search_params
        expect(response).to have_http_status :ok
      end

      it 'renders searches/new' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/new')
      end

      it 'renders searches/_results' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_results')
      end

      it 'queries JSON API client' do
        post '/searches', params: search_params
        expect(client).to have_received(:query).and_return(data)
      end

      it 'returns array of results' do
        allow(client).to receive(:query).and_return(data)
        post '/searches', params: search_params
        expect(assigns(:results)).to be_an Array
      end
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

  describe 'validate test json' do
    let(:schema) { File.read './config/schemas/prosecution_case_search_result.json' }
    let(:data) do
      File.read(Rails.root.join('spec', 'fixtures', 'prosecution_cases', 'valid_response.json'))
    end

    it 'data is valid for schema' do
      errors = JSON::Validator.fully_validate(schema, data, strict: true, validate_schema: true)
      expect(errors).to be_empty
    end
  end
end
