# frozen_string_literal: true

RSpec.describe 'case reference search', :stub_defendants_case_search, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'renders searches#new to Search by caseReference' do
    get '/searches/new', params: { search: { filter: :case_reference } }
    expect(response.body).to include('Unique reference number')
  end

  context 'when posting a query' do
    let(:search_params) do
      { search: { term: 'MOGUERBXIZ', filter: :case_reference } }
    end

    before do
      post '/searches', params: search_params
    end

    it 'accepts query paramater' do
      expect(response).to have_http_status :ok
    end

    context 'when results returned' do
      it 'assigns array of results' do
        expect(response.body).to include('4 search results')
      end

      it 'renders searches/_results' do
        expect(response.body).to include('search result')
      end

      it 'renders results/_defendant' do
        expect(response.body).to include('ASN')
      end
    end

    context 'when no results', :stub_no_v2_results do
      before do
        allow_any_instance_of(Search).to receive(:execute).and_return([])
        post '/searches', params: { search: { term: 'T20200001', filter: :case_reference } }
      end

      it 'renders searches/_results_header' do
        expect(response.body).to include('search result')
      end

      it 'renders results/_none template' do
        expect(response.body).to include('There are no matching results.')
      end
    end
  end
end
