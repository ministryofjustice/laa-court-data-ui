# frozen_string_literal: true

RSpec.describe 'managers', type: :request do
  let(:user) { create(:user, :with_manager_role) }
  let(:other_user) { create(:user, :with_caseworker_role) }

  before do
    sign_in user
  end

  describe 'Show user', type: :request do
    it 'can render /users/:id' do
      get "/users/#{user.id}"
      expect(response).to render_template('users/show')
    end

    it 'can render other /users/:id' do
      get "/users/#{other_user.id}"
      expect(response).to render_template('users/show')
    end
  end

  describe 'Edit user', type: :request do
    it 'renders /users/:id/edit' do
      get "/users/#{user.id}/edit"
      expect(response).to render_template('users/edit')
    end

    it 'renders other /users/:id/edit' do
      get "/users/#{other_user.id}/edit"
      expect(response).to render_template('users/edit')
    end
  end

  describe 'Update user', type: :request do
    context 'when themself' do
      before do
        patch "/users/#{user.id}", params: { user: { email: 'updated@example.com' } }
      end

      it 'redirects to /users/:id' do
        expect(response).to redirect_to user_path(user)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/success/)
      end

      it 'updates user' do
        expect(user.reload.email).to eql 'updated@example.com'
      end
    end

    context 'when other user' do
      before do
        patch "/users/#{other_user.id}", params: { user: { email: 'updatedother@example.com' } }
      end

      it 'redirects to /users/:id' do
        expect(response).to redirect_to user_path(other_user)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/success/)
      end

      it 'updates other user' do
        expect(other_user.reload.email).to eql 'updatedother@example.com'
      end
    end
  end

  describe 'Edit user password', type: :request do
    it 'can render /users/:id/change_password' do
      get "/users/#{user.id}/change_password"
      expect(response).to render_template('users/change_password')
    end

    it 'can render other /users/:id/change_password' do
      get "/users/#{other_user.id}/change_password"
      expect(response).to render_template('users/change_password')
    end
  end

  describe 'Update user password', type: :request do
    let(:password_params) do
      {
        user: {
          current_password: user.password,
          password: 'testing1234',
          password_confirmation: 'testing1234'
        }
      }
    end

    context 'when themself' do
      before do
        patch "/users/#{user.id}/update_password", params: password_params
      end

      it 'can update their password' do
        expect(response).to redirect_to user_path(user)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/success/)
      end
    end

    context 'when other user' do
      before do
        patch "/users/#{other_user.id}/update_password", params: password_params
      end

      it 'can update other users password' do
        expect(response).to redirect_to user_path(other_user)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/success/)
      end
    end
  end
end
