# frozen_string_literal: true

RSpec.describe 'authorization', type: :request do
  let(:other_user) { create(:user, roles: ['caseworker']) }

  context 'when caseworker signed in' do
    let(:user) { create(:user, roles: ['caseworker']) }

    before { sign_in user }

    it 'can search' do
      get new_search_filter_path
      expect(response).to render_template('search_filters/new')
    end

    # TODO: needs expanding once edit, etc are added
    it 'can manage themselves' do
      get user_path(user)
      expect(response).to render_template('users/show')
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

  context 'when manager signed in' do
    let(:user) { create(:user, roles: ['manager']) }

    before { sign_in user }

    it 'can manage themselves' do
      get user_path(user)
      expect(response).to render_template('users/show')
    end

    it 'can manage other users' do
      get user_path(other_user)
      expect(response).to render_template('users/show')
    end
  end
end
