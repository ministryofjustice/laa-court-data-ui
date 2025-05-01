# frozen_string_literal: true

RSpec.describe 'case reference search', :stub_defendants_case_search, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'renders searches#new' do
    get '/searches/new', params: { search: { filter: :case_reference } }
    expect(response).to render_template('searches/new')
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

    it 'renders searches/new' do
      expect(response).to render_template('searches/new')
    end

    context 'when results returned' do
      it 'assigns array of results' do
        expect(assigns(:results))
          .to include(an_instance_of(CdApi::Defendant))
      end

      it 'renders searches/_results' do
        expect(response).to render_template('searches/_results')
      end

      it 'renders results/_defendant' do
        expect(response).to render_template('results/_defendant')
      end
    end

    context 'when no results', :stub_no_v2_results do
      before do
        allow_any_instance_of(Search).to receive(:execute).and_return([])
        post '/searches', params: { search: { term: 'T20200001', filter: :case_reference } }
      end

      it 'renders searches/_results_header' do
        expect(response).to render_template('searches/_results_header')
      end

      it 'renders results/_none template' do
        expect(response).to render_template('results/_none')
      end
    end

    context 'when appeals flag is true', :stub_defendants_case_search do
      before do
        allow(FeatureFlag).to receive(:enabled?).with(:show_appeals).and_return(true)
        post '/searches', params: { search: { term: 'T20200001', filter: :case_reference } }
      end

      it 'renders searches/_results_header' do
        expect(response).to render_template('searches/_results_header')
      end

      it 'renders results/_defendant_appeals partial' do
        expect(response).to render_template('results/_defendant_appeals')
      end

      it 'renders results/_defendant_court_applications partial' do
        expect(response).to render_template('results/_defendant_court_applications')
      end

      it 'renders court application title' do
        expect(response.body).to include('Appeal for conviction')
      end

      it 'renders header court application title' do
        expect(response.body).to include('Related applications')
      end

      it 'not header National Insurance number' do
        expect(response.body).not_to include('NI number')
      end
    end
  end
end
