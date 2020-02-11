# frozen_string_literal: true

RSpec.describe 'defendant search', type: :request, stub_no_results: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'renders searches#new' do
    get '/searches/new', params: { search: { filter: :defendant } }
    expect(response).to render_template('searches/new')
  end

  context 'when posting a query' do
    let(:search_params) do
      {
        search:
        {
          filter: :defendant,
          term: 'mini mouse',
          'dob(3i)': '21',
          'dob(2i)': '05',
          'dob(1i)': '1987'
        }
      }
    end

    it 'accepts query paramater' do
      post '/searches', params: search_params
      expect(response).to have_http_status :ok
    end

    it 'renders searches/new' do
      post '/searches', params: search_params
      expect(response).to render_template('searches/new')
    end

    context 'when results returned', stub_defendant_results: true do
      it 'assigns array of results' do
        post '/searches', params: search_params
        expect(assigns(:results))
          .to include(an_instance_of(CourtDataAdaptor::Resource::ProsecutionCase))
      end

      it 'renders searches/_results' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_results')
      end

      it 'renders searches/_results_header' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_results_header')
      end

      it 'does not render searches/_no_results' do
        post '/searches', params: search_params
        expect(response).not_to render_template('searches/_no_results')
      end
    end

    context 'when no results', type: :request, stub_no_results: true do
      before do
        allow_any_instance_of(Search).to receive(:execute).and_return([])
      end

      it 'renders searches/_results_header' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_results_header')
      end

      it 'renders searches/_no_results template' do
        post '/searches', params: search_params
        expect(response).to render_template('searches/_no_results')
      end
    end
  end
end
