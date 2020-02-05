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

  context 'when searching by case', type: :request, stub_no_results: true do
    it 'renders searches#new' do
      get '/searches/new', params: { search: { filter: :case_reference } }
      expect(response).to render_template('searches/new')
    end

    context 'when posting a query' do
      let(:search_params) do
        { search: { query: '05PP1000915', filter: :case_reference } }
      end

      it 'accepts query paramater' do
        post '/searches', params: search_params
        expect(response).to have_http_status :ok
      end

      it 'renders searches/new' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/new')
      end

      it 'assigns array of results', stub_case_reference_results: true do
        post '/searches', params: search_params
        expect(assigns(:results)).to include(an_instance_of(CourtDataAdaptor::ProsecutionCase))
      end

      it 'renders searches/_results', stub_case_reference_results: true do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_results')
      end

      it 'renders searches/_no_results', stub_case_reference_results: true do
        post '/searches', params: search_params
        expect(response).not_to render_template('searches/_no_results')
      end
    end
  end

  context 'when no results', type: :request do
    before do
      allow_any_instance_of(Search).to receive(:execute).and_return([])
    end

    it 'renders searches/_no_results template' do
      post '/searches', params: { search: { query: 'T20200001', filter: :case_number } }
      expect(response).to render_template('searches/_no_results')
    end
  end
end
