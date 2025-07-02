# frozen_string_literal: true

class UsersController < ApplicationController
  require 'csv'
  load_and_authorize_resource except: :create

  def index
    session.delete(:user_search)
    @user_search = UserSearch.new
    @pagy, @users = pagy(@users.by_name)
  end

  def search
    @user_search = UserSearch.new(search_params)
    @pagy, @users = pagy(UserSearchService.call(@user_search, @users.by_name))
    render :index
  end

  def show; end

  def new; end

  def edit; end

  def create
    @user = build_user
    authorize!(:create, @user)

    if @user.save
      redirect_to @user, notice: I18n.t('users.create.flash.success')
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    email_changed = @user.email_changed?
    if @user.save
      Devise::Mailer.email_changed(@user).deliver_later if email_changed
      redirect_to @user, notice: I18n.t('users.update.flash.success')
    else
      render :edit
    end
  end

  def export
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment;filename=users.csv'
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, status: :see_other, notice: I18n.t('users.destroy.flash.success')
  end

  private

  def user_params
    params[:user][:roles]&.reject!(&:blank?)
    params.require(:user).permit(
      :last_name,
      :first_name,
      :username,
      :email,
      :email_confirmation,
      roles: [],
      feature_flags: []
    ).tap { it[:feature_flags]&.reject!(&:blank?) }
  end

  def build_user
    User.new(user_params)
  end

  def search_params
    if params[:user_search]
      params.require(:user_search).permit(
        :search_string,
        :recent_sign_ins,
        :old_sign_ins
      ).tap { session[:user_search] = session_safe(it) }
    else
      session[:user_search]
    end
  end
end
