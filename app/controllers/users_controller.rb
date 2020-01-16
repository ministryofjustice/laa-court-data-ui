# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :set_user, only: %i[show edit update]

  def show; end

  def edit; end

  def update
    if @user.update!(user_params)
      redirect_to authenticated_root_path
    else
      render :edit
    end
  end

  private

  def set_user
    # @user = User.find(params[:id])
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:last_name, :first_name, :email)
  end
end
