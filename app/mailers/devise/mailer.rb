# frozen_string_literal: true

module Devise
  class Mailer < GovukNotifyRails::Mailer
    include Devise::Controllers::UrlHelpers
    include ActionView::Helpers::DateHelper

    GOVUK_NOTIFY_TEMPLATES = {
      email_changed: '6e720ef6-de86-4f78-ad71-786ad2687203'
    }.freeze

    def email_changed(user, _opts = {})
      set_template(GOVUK_NOTIFY_TEMPLATES[:email_changed])
      set_personalisation(
        user_full_name: user.name,
        user_new_email: user.email
      )
      mail(to: user.email_before_last_save)
    end
  end
end
