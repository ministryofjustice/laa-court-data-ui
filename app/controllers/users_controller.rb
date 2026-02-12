# frozen_string_literal: true

class UsersController < ApplicationController # rubocop:disable Metrics/ClassLength
  require 'csv'
  load_and_authorize_resource except: :create

  add_breadcrumb I18n.t('users.breadcrumb.home'), :new_search_filter_path
  add_breadcrumb I18n.t('users.breadcrumb.manage_users'), :users_path

  def index
    session.delete(:user_search)
    @user_search = UserSearch.new
    order = params[:user_sort_direction] == "desc" ? "desc" : "asc"
    column = params[:user_sort_column]
    if %w[username email roles last_sign_in_at name].include?(column)
      @pagy, @users = order_by(column, order)
    else
      @pagy, @users = pagy(@users.by_name)
    end
  end

  def search
    @user_search = UserSearch.new(search_params)
    @pagy, @users = pagy(UserSearchService.call(@user_search, @users.by_name))
    render :index
  end

  def show
    add_breadcrumb @user.name
  end

  def new
    add_breadcrumb I18n.t('users.breadcrumb.new_user')
  end

  def edit
    add_breadcrumb @user.name
  end

  def confirm_delete
    add_breadcrumb I18n.t('users.breadcrumb.delete_user')
  end

  def create
    @user = build_user
    authorize!(:create, @user)

    if @user.save
      redirect_to @user, flash: { success_moj_banner: I18n.t('users.create.flash.success') }
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    email_changed = @user.email_changed?
    if @user.save
      Devise::Mailer.email_changed(@user).deliver_later if email_changed
      redirect_to @user, flash: { success_moj_banner: I18n.t('users.update.flash.success') }
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
    redirect_to users_path,
                status: :see_other,
                flash: {
                  success_moj_banner: I18n.t('users.destroy.flash.success')
                }
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
        :old_sign_ins,
        :manager_role,
        :caseworker_role,
        :admin_role,
        :data_analyst_role
      ).tap { session[:user_search] = session_safe(it) }
    else
      session[:user_search]
    end
  end

  def order_by(column, order)
    direction = order == "asc" ? :asc : :desc
    if column == 'name'
      @pagy, @users = pagy(@users.order(first_name: direction, last_name: direction))
    else
      @pagy, @users = pagy(@users.order("#{column}": direction))
    end
  end
end # rubocop:enable Metrics/ClassLength
