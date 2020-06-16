# frozen_string_literal: true

RSpec.describe 'managers', type: :request do
  let(:user) { create(:user, :with_manager_role) }
  let(:other_user) { create(:user, :with_caseworker_role) }
  let(:message_delivery) { instance_double(GovukNotifyRails::Mailer::MessageDelivery) }

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

  describe 'New user', type: :request do
    before do
      get '/users/new'
    end

    it 'renders /users/new' do
      expect(response).to render_template('users/new')
    end
  end

  describe 'Create user', type: :request do
    before do
      allow(Devise::Mailer).to receive(:reset_password_instructions).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    let(:user_params) do
      {
        user:
          {
            first_name: 'Billy',
            last_name: 'Bob',
            username: 'bob-b',
            email: 'created@example.com',
            email_confirmation: 'created@example.com'
          }
      }
    end

    let(:new_user) { User.find_by(email: 'created@example.com') }
    let(:request) { post '/users', params: user_params }

    it 'redirects to user_path' do
      request
      expect(response).to redirect_to user_path(new_user)
    end

    it 'sends password reset email' do
      request
      expect(Devise::Mailer).to have_received(:reset_password_instructions)
    end

    it 'flashes notice' do
      request
      expect(flash.now[:notice]).to match(/success/)
    end

    it 'creates user' do
      expect { request }.to change(User, :count).by(1)
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
    let(:user_params) do
      { user: { email: 'updated@example.com', email_confirmation: 'updated@example.com' } }
    end

    context 'when themself' do
      before do
        allow(Devise::Mailer).to receive(:email_changed).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        patch "/users/#{user.id}", params: user_params
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

      it 'sends email changed email' do
        expect(Devise::Mailer).to have_received(:email_changed)
      end
    end

    context 'when other user' do
      before do
        allow(Devise::Mailer).to receive(:email_changed).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        patch "/users/#{other_user.id}", params: user_params
      end

      it 'redirects to /users/:id' do
        expect(response).to redirect_to user_path(other_user)
      end

      it 'flashes alert' do
        expect(flash.now[:notice]).to match(/success/)
      end

      it 'updates other user' do
        expect(other_user.reload.email).to eql 'updated@example.com'
      end

      it 'sends email changed email' do
        expect(Devise::Mailer).to have_received(:email_changed)
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
        allow(Devise::Mailer).to receive(:password_change).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        patch "/users/#{user.id}/update_password", params: password_params
      end

      it 'can update their password' do
        expect(response).to redirect_to user_path(user)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/success/)
      end

      it 'sends password change email' do
        expect(Devise::Mailer).to have_received(:password_change)
      end
    end

    context 'when other user' do
      before do
        allow(Devise::Mailer).to receive(:password_change).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
        patch "/users/#{other_user.id}/update_password", params: password_params
      end

      it 'can update other users password' do
        expect(response).to redirect_to user_path(other_user)
      end

      it 'flashes notice' do
        expect(flash.now[:notice]).to match(/success/)
      end

      it 'sends password change email' do
        expect(Devise::Mailer).to have_received(:password_change)
      end
    end
  end

  describe 'Destroy user', type: :request do
    let!(:other_user) { create(:user, :with_caseworker_role) }
    let(:request) { delete "/users/#{other_user.id}" }

    it 'deletes the user' do
      expect { request }.to change(User, :count).by(-1)
    end

    it 'redirects to users index' do
      request
      expect(response).to redirect_to users_path
    end

    it 'flashes notice' do
      request
      expect(flash.now[:notice]).to match(/success/)
    end
  end
end
