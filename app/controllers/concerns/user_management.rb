module UserManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_breadcrumbs
  end

  def set_breadcrumbs
    add_breadcrumb I18n.t('users.breadcrumb.home'), :new_search_filter_path

    add_breadcrumb I18n.t('users.breadcrumb.manage_users'), :users_path if current_user.admin?
  end

  def search
    @user_search = UserSearch.new(search_params)
    @pagy, @users = pagy(UserSearchService.call(@user_search, @users.by_name))
    render :index
  end

  def search_params
    if params[:user_search]
      params.require(:user_search).permit(
        :search_string,
        :recent_sign_ins,
        :old_sign_ins,
        :caseworker_role,
        :admin_role,
        :data_analyst_role
      ).tap { session[:user_search] = session_safe(it) }
    else
      session[:user_search]
    end
  end
end
