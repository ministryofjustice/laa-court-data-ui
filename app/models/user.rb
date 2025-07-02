# frozen_string_literal: true

class User < ApplicationRecord
  include Roles

  # Include default devise modules. Others available are:
  # :confirmable, :registerable and :omniauthable
  devise  :omniauthable,
          :timeoutable,
          :trackable,
          :lockable,
          :validatable

  accepts_roles :caseworker, :manager, :admin

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[\w-]{1,10}\z/ }
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?

  attr_writer :login

  def login
    @login || username || email
  end

  def name
    "#{first_name} #{last_name}"
  end

  # To enable Devise emails to be delivered in the background.
  # https://github.com/heartcombo/devise#activejob-integration
  #
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def password_required?
    false
  end

  # Devise::Validatable expects a password attribute, but with SSO we don't have one.
  def password
    nil
  end
end
