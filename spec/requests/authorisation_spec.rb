# frozen_string_literal: true

RSpec.shared_examples 'a standard user' do
  it 'can search' do
    get new_search_filter_path
    expect(response.body).to include('<h1 class="govuk-fieldset__heading">Search for</h1>')
  end

  # TODO: needs expanding once edit, etc are added
  it 'can manage themselves' do
    get user_path(user)
    expect(response.body).to include('User details')
  end

  context 'when performing unauthorized action on user' do
    before { get user_path(other_user) }

    it 'redirects to root' do
      expect(response).to redirect_to authenticated_root_path
    end

    it 'flashes alert' do
      expect(flash.now[:alert]).to match(/You are unauthorised to manage users/)
    end
  end
end

RSpec.describe 'authorization', type: :request do
  let(:other_user) { create(:user, roles: ['caseworker']) }

  context 'when caseworker signed in' do
    let(:user) { create(:user, roles: ['caseworker']) }

    before { sign_in user }

    it_behaves_like('a standard user')
  end

  context 'when admin signed in' do
    let(:user) { create(:user, roles: ['admin']) }

    before { sign_in user }

    it 'can manage themselves' do
      get user_path(user)
      expect(response.body).to include('User details')
    end

    it 'can manage other users' do
      get user_path(other_user)
      expect(response.body).to include('User details')
    end
  end

  context 'when admin performing unauthorized action on case' do
    let(:user) { create(:user, roles: ['admin']) }

    before {
      sign_in user
      get new_search_filter_path
    }

    it 'redirects to root' do
      expect(response).to redirect_to authenticated_admin_root_path
    end

    it 'flashes alert' do
      expect(flash.now[:alert]).to match(/You are unauthorised to new Search filter/)
    end
  end
end
