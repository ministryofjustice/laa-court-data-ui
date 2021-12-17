# class WelcomeMailer < ApplicationMailer
#   def welcome
#     mail(to: 'contact@mabel.li', subject: 'Letter opener test')
#   end
# end

class WelcomeMailer < GovukNotifyRails::Mailer
  def welcome
    set_template('5fcd84b1-8d05-4b6c-86a8-9fc391efa754')
    set_personalisation(
      email: 'someone@example.com',
      rating:'4',
      comment: 'something',
      environment: 'development'
    )
    mail(to: 'contact@mabel.li', subject: 'Letter opener test')
  end
end
