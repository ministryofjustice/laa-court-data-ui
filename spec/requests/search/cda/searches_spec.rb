# frozen_string_literal: true

RSpec.describe 'Searches', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe '#new' do
    before { get '/searches/new', params: params }

    context 'without a query' do
      let(:params) { { search: { filter: 'case_reference' } } }

      it 'returns successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays case reference search form' do
        expect(response.body).to include('Unique reference number')
      end

      it 'does not show validation errors' do
        expect(response.body).not_to include('There is a problem')
      end

      it 'does not display results' do
        expect(response.body).not_to include('search results')
      end
    end

    context 'when there are no search params' do
      let(:params) { nil }

      it 'redirects to the new_searches_filter_path' do
        expect(response).to redirect_to(new_search_filter_path)
      end
    end
  end

  describe 'POST #create' do
    before { post '/searches', params: params }

    context 'when POSTing a valid case search', :stub_defendants_case_search do
      let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

      it 'displays search results' do
        expect(response.body).to include('search results')
      end

      it 'returns successful response' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when POSTing an invalid case search', :stub_defendants_case_search do
      let(:params) { { search: { filter: 'case_reference', term: nil } } }

      it 'shows validation errors' do
        expect(response.body).to include('There is a problem')
      end
    end

    # ...existing contexts for defendant searches...

    context 'when there are no results', :stub_no_v2_case_results do
      let(:params) { { search: { filter: 'case_reference', term: 'whatever' } } }

      it 'shows no results message' do
        expect(response.body).to include('There are no matching results')
      end

      it 'returns successful response' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when POSTing a valid defendant name search', :stub_defendants_name_search do
      let(:params) do
        {
          search:
          {
            filter: 'defendant_name',
            term: 'Jammy Dodger',
            'dob(1i)' => '1987',
            'dob(2i)' => '05',
            'dob(3i)' => '21'
          }
        }
      end

      it 'displays search results' do
        expect(response.body).to include('ASN')
      end
    end
  end

  describe 'GET #create', :stub_defendants_case_search do
    before { get '/searches', params: params }

    context 'when GETing a valid search' do
      let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

      it 'displays search results' do
        expect(response.body).to include('search results')
      end
    end

    # ...existing contexts...
  end

  context 'when there is a connection error' do
    before do
      allow(Rails.env).to receive(:production?).and_return true
      allow_any_instance_of(Search)
        .to receive(:execute)
        .and_raise ActiveResource::ServerError.new('connection error test')
      get '/searches', params:
    end

    let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

    it { expect(flash[:alert][:title]).to match(/.*Unable to complete the search.*/) }
  end

  context 'when there is a net read timeout error' do
    before do
      allow(Rails.env).to receive(:production?).and_return true
      allow_any_instance_of(Search)
        .to receive(:execute)
        .and_raise Net::ReadTimeout.new('read timeout error test')
      get '/searches', params:
    end

    let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

    it { expect(flash[:alert]).to match(/There was a problem/) }
    it { expect(response).to redirect_to(authenticated_root_path) }
  end
end
