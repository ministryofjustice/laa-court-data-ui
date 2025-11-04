# frozen_string_literal: true

RSpec.describe 'Defendant by name and dob search', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'renders searches#new' do
    get '/searches/new', params: { search: { filter: :defendant_name } }
    expect(response.body).to include('Defendant date of birth')
  end

  context 'when posting a query', :stub_defendants_name_search do
    let(:search_params) do
      {
        search:
        {
          filter: :defendant_name,
          term: 'trever glover',
          "dob(3i)": '1',
          "dob(2i)": '1',
          "dob(1i)": '1990'
        }
      }
    end

    it 'accepts query paramater' do
      post '/searches', params: search_params
      expect(response).to have_http_status :ok
    end

    it 'renders searches/new' do
      post '/searches', params: search_params
      expect(response.body).to include('search')
    end

    context 'when results returned', :vcr do
      before { post '/searches', params: search_params }

      it 'assigns array of results' do
        expect(response.body).to include('4 search results')
      end

      it 'renders searches/_results' do
        expect(response.body).to include('search result')
      end

      it 'renders searches/_results_header' do
        expect(response.body).to include('search result')
      end

      it 'renders results/_defendant' do
        expect(response.body).to include('ASN')
      end
    end

    context 'when no results', :stub_no_v2_results, type: :request do
      before do
        allow_any_instance_of(Search).to receive(:execute).and_return([])
        post '/searches', params: search_params
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
