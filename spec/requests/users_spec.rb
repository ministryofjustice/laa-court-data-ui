# frozen_string_literal: true

RSpec.fdescribe 'users', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'Show user profile page', type: :request do
    it 'renders /users/:id' do
      get "/users/#{user.id}"
      expect(response).to render_template('users/show')
    end
  end

  describe 'Edit user profile page', type: :request do
    it 'renders /users/:id/edit' do
      get "/users/#{user.id}/edit"
      expect(response).to render_template('users/edit')
    end

    it 'allows users to update their details' do
      patch "/users/#{user.id}", params: { user: { user: { first_name: 'updated' } } }
      expect(response).to redirect_to authenticated_root_path
    end
  end

  describe 'Change users password', type: :request do
    it 'renders /users/:id/change_password' do
      get "/users/#{user.id}/change_password"
      expect(response).to render_template('users/change_password')
    end

    it 'allows users to update their password' do
      patch "/users/#{user.id}", params: { user: { password: 'testing1234',
                                                    password_confirmation: 'testing1234' } }
      expect(response).to redirect_to authenticated_root_path
    end
  end
end
