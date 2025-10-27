# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_authorization_check only: %i[new create destroy update_cookies fake]

  def after_sign_in_path_for(user)
    if user.data_analyst?
      new_stats_path
    else
      new_search_filter_path
    end
  end

  def destroy
    super do
      # Turbo requires redirects be :see_other (303); so override Devise default (302)
      return redirect_to after_sign_out_path_for(resource_name), status: :see_other
    end
  end

  def fake
    redirect_to unauthenticated_root_path unless FeatureFlag.enabled?(:fake_auth)
    sign_in User.find(params[:user_id])
    redirect_to authenticated_root_path
  end

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
