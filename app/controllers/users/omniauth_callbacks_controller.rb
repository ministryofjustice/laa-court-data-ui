module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_authorization_check

    def entra
      user = User.find_by(entra_id: entra_details.uid)
      if user # User is found by entra_id, which means they already logged in at least once
        user.update!(email: entra_email, email_confirmation: entra_email)
      else
        user = User.find_by(entra_id: nil, email: entra_email)
        user&.update!(entra_id: entra_details.uid) # User is found by email and no entra_id, which means it's their first login
      end

      if user
        sign_in user
        redirect_to authenticated_user_root_path(user)
      else
        redirect_to unauthenticated_root_path, flash: { alert: t('devise.failure.user.unauthorised') }
      end
    end

    private

    def authenticated_user_root_path(user)
      user.admin? ? authenticated_admin_root_path : authenticated_root_path
    end

    def after_omniauth_failure_path_for(_scope)
      unauthenticated_root_path
    end

    def entra_email
      entra_details.info.email.downcase
    end

    def entra_details
      @entra_details ||= request.env['omniauth.auth']
    end
  end
end
