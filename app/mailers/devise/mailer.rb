# frozen_string_literal: true

module Devise
  class Mailer < GovukNotifyRails::Mailer
    include Devise::Controllers::UrlHelpers
    include ActionView::Helpers::DateHelper

    GOVUK_NOTIFY_TEMPLATES = {
      reset_password_instructions: '7314475f-62b0-41bf-8aff-768427cba456',
      password_change: 'f72ca643-192a-476e-8f62-2a7e7c662e98',
      email_changed: '6e720ef6-de86-4f78-ad71-786ad2687203',
      unlock_instructions: '18d9fde2-6ce6-48a9-8892-611733d69e26'
    }.freeze

    def reset_password_instructions(user, token, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:reset_password_instructions])
      set_personalisation(
        user_full_name: user.name,
        edit_password_url: edit_password_url(user, reset_password_token: token),
        token_expiry_days: distance_of_time_in_words(User.reset_password_within),
        password_reset_url: new_user_password_url
      )
      mail(to: user.email)
    end

    def password_change(user, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:password_change])
      set_personalisation(
        user_full_name: user.name
      )
      mail(to: user.email)
    end

    def email_changed(user, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:email_changed])
      set_personalisation(
        user_full_name: user.name,
        user_new_email: user.email
      )
      mail(to: user.email_before_last_save)
    end

    def unlock_instructions(user, token, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:unlock_instructions])
      set_personalisation(
        user_full_name: user.name,
        unlock_url: unlock_url(user, unlock_token: token)
      )
      mail(to: user.email)
    end
  end
end
