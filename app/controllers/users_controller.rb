# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :set_user, only: %i[show edit update]

  before_action :set_user, only: %i[show edit update change_password update_password]

  def show; end

  def edit; end

  def change_password; end

  def update_password
    if current_user.update_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to authenticated_root_path, notice: 'Password successfully updated'
    else
      render :change_password
    end
  end

  def update
    if @user.update!(user_params)
      redirect_to authenticated_root_path, notice: 'User details successfully updated'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :last_name,
      :first_name,
      :email,
      :current_password,
      :password,
      :password_confirmation
    )
  end
end
