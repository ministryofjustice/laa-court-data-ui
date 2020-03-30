# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource except: :create

  def index; end

  def show; end

  def new; end

  def create
    @user = build_user
    authorize!(:create, @user)

    if @user.save
      @user.send_reset_password_instructions
      redirect_to @user, notice: I18n.t('users.create.flash.success')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: I18n.t('users.update.flash.success')
    else
      render :edit
    end
  end

  def change_password; end

  def update_password
    if @user.update_with_password(user_params)
      bypass_sign_in(@user)
      redirect_to @user, notice: I18n.t('users.update_password.flash.success')
    else
      render :change_password
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: I18n.t('users.destroy.flash.success')
  end

  private

  def user_params
    params[:user][:roles]&.reject!(&:blank?)
    params.require(:user).permit(
      :last_name,
      :first_name,
      :email,
      :email_confirmation,
      :current_password,
      :password,
      :password_confirmation,
      roles: []
    )
  end

  def build_user
    tmp_password = SecureRandom.uuid
    User.new(
      user_params.merge!(
        password: tmp_password,
        password_confirmation: tmp_password
      )
    )
  end
end
