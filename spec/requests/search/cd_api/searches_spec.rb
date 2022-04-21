# frozen_string_literal: true

RSpec.describe 'Searches', type: :request do
  let(:user) { create(:user) }

  before do
    allow(Feature).to receive(:enabled?).with('DEFENDANTS_SEARCH').and_return(true)
    sign_in user
  end

  describe '#new' do
    before { get '/searches/new', params: }

    context 'without a query' do
      let(:params) { { search: { filter: 'case_reference' } } }

      it { expect(response).to render_template('searches/new') }
      it { expect(response).to render_template('searches/_form') }
      it { expect(response).not_to render_template('searches/_results') }
      it { expect(response.body).not_to include('There is a problem') }
    end
  end

  describe 'POST #create' do
    before { post '/searches', params: }

    context 'when POSTing a valid case search', stub_defendants_case_search: true do
      let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

      include_examples 'renders results'
      it { expect(response).to render_template('results/_defendant') }
    end

    context 'when POSTing an invalid case search', stub_defendants_case_search: true do
      let(:params) { { search: { filter: 'case_reference', term: nil } } }

      include_examples 'renders search validation errors'
    end

    context 'when POSTing a valid defendant ASN or NINO search', stub_defendants_ref_search: true do
      let(:params) { { search: { filter: 'defendant_reference', term: 'JC123456A' } } }

      include_examples 'renders results'
      it { expect(response).to render_template('results/_defendant') }
    end

    context 'when POSTing a invalid defendant ASN or NINO search', stub_defendants_ref_search: true do
      let(:params) { { search: { filter: 'defendant_reference', term: nil } } }

      include_examples 'renders search validation errors'
    end

    context 'when POSTing a valid defendant name search', stub_defendants_name_search: true do
      let(:params) do
        {
          search:
          {
            filter: 'defendant_name',
            term: 'Jammy Dodger',
            'dob(1i)' => '21',
            'dob(2i)' => '05',
            'dob(3i)' => '1987'
          }
        }
      end

      include_examples 'renders results'
      it { expect(response).to render_template('results/_defendant') }
    end

    context 'when POSTing an invalid defendant name search', stub_defendant_name_search: true do
      context 'with partial date' do
        let(:params) do
          {
            search:
            {
              filter: 'defendant_name',
              term: 'Jammy Dodger',
              'dob(1i)' => '21',
              'dob(2i)' => '05',
              'dob(3i)' => ''
            }
          }
        end

        include_examples 'renders search validation errors'
      end

      context 'with invalid date' do
        let(:params) do
          {
            search:
            {
              filter: 'defendant_name',
              term: 'Jammy Dodger',
              'dob(1i)' => '32',
              'dob(2i)' => '05',
              'dob(3i)' => '1987'
            }
          }
        end

        include_examples 'renders search validation errors'
      end
    end

    context 'when there are no results', stub_no_results: true do
      let(:params) { { search: { filter: 'case_reference', term: 'whatever' } } }

      it { expect(response).to render_template('searches/new') }
      it { expect(response).to render_template('searches/_form') }
      it { expect(response).to render_template('searches/_results') }
      it { expect(response).to render_template('results/_none') }
    end
  end

  describe 'GET #create', stub_defendants_case_search: true do
    before { get '/searches', params: }

    context 'when GETing a valid search' do
      let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

      include_examples 'renders results'
    end

    context 'when GETing an invalid search' do
      let(:params) { { search: { filter: 'case_reference', term: nil } } }

      include_examples 'renders search validation errors'
    end
  end

  context 'when there is a connection error' do
    before do
      allow(Rails.env).to receive(:production?).and_return true
      allow_any_instance_of(Search)
        .to receive(:execute)
        .and_raise JsonApiClient::Errors::ConnectionError.new('connection error test')
      get '/searches', params:
    end

    let(:params) { { search: { filter: 'case_reference', term: 'test12345' } } }

    it { expect(flash[:alert]).to match(/There was a problem/) }
    it { expect(response).to redirect_to(authenticated_root_path) }
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
