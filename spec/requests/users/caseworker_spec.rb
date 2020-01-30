# frozen_string_literal: true

RSpec.describe 'caseworkers', type: :request do
  let(:user) { create(:user, :with_caseworker_role) }
  let(:other_user) { create(:user, :with_caseworker_role) }

  before do
    sign_in user
  end

  describe 'Show user', type: :request do
    context 'when themself' do
      it 'renders /users/:id' do
        get "/users/#{user.id}"
        expect(response).to render_template('users/show')
      end
    end

    context 'when other user' do
      before do
        get "/users/#{other_user.id}"
      end

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end
    end
  end

  describe 'New user', type: :request do
    context 'when themself' do
      before do
        get '/users/new'
      end

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end
    end
  end

  describe 'Create user', type: :request do
    context 'when themself' do
      let(:user_params) do
        {
          user:
            {
              first_name: 'Billy',
              last_name: 'Bob',
              email: 'created@example.com',
              email_confirmation: 'created@example.com'
            }
        }
      end

      let(:request) { post '/users', params: user_params }

      it 'redirects to authenticated_root_path' do
        request
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        request
        expect(flash.now[:alert]).to match(/unauthorised/)
      end

      it 'does not create user' do
        expect { request }.not_to change(User, :count)
      end
    end
  end

  describe 'Edit user', type: :request do
    context 'when themself' do
      before do
        get "/users/#{user.id}/edit"
      end

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end
    end
  end

  describe 'Update user', type: :request do
    context 'when themself' do
      before do
        patch "/users/#{user.id}", params: { user: { email: 'updated@example.com' } }
      end

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end

      it 'does not update user' do
        expect(user.reload.email).not_to eql 'updated@example.com'
      end
    end
  end

  describe 'Edit user password', type: :request do
    context 'when themself' do
      it 'render /users/:id/change_password' do
        get "/users/#{user.id}/change_password"
        expect(response).to render_template('users/change_password')
      end
    end

    context 'when other user' do
      before do
        get "/users/#{other_user.id}/change_password"
      end

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end
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

      it 'redirects to /users/:id' do
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

      it 'redirects to authenticated_root_path' do
        expect(response).to redirect_to authenticated_root_path
      end

      it 'flashes alert' do
        expect(flash.now[:alert]).to match(/unauthorised/)
      end
    end
  end

  describe 'Destroy user', type: :request do
    let!(:other_user) { create(:user, :with_caseworker_role) }
    let(:request) { delete "/users/#{other_user.id}" }

    it 'does not delete the user' do
      expect { request }.not_to change(User, :count)
    end

    it 'redirects to authenticated_root_path' do
      request
      expect(response).to redirect_to authenticated_root_path
    end

    it 'flashes alert' do
      request
      expect(flash.now[:alert]).to match(/unauthorised/)
    end
  end
end
