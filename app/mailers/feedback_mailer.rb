# frozen_string_literal: true

class FeedbackMailer < GovukNotifyRails::Mailer
  def notify(email:, rating:, environment:, comment: nil)
    set_template('5fcd84b1-8d05-4b6c-86a8-9fc391efa754')
    set_personalisation(
      email: email,
      rating: rating,
      comment: comment,
      environment: environment
    )
    mail(to: support_email_address)
  end

  private

  def support_email_address
    Rails.configuration.x.support_email_address
  end
end
