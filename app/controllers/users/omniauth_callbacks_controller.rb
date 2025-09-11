module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_authorization_check

    def entra
      user = User.find_by(entra_id: entra_details.uid) || User.find_by(entra_id: nil, email: entra_email)
      if user
        user.update!(entra_id: entra_details.uid,
                     email: entra_email,
                     email_confirmation: entra_email)
        sign_in user
        redirect_to authenticated_root_path, flash: { notice: t('devise.sessions.user.signed_in') }
      else
        redirect_to unauthenticated_root_path, flash: { alert: t('devise.failure.user.unauthorised') }
      end
    end

    private

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
