# frozen_string_literal: true

class User < ApplicationRecord
  include Roles

  # Include default devise modules. Others available are:
  # :confirmable, :registerable and :omniauthable
  devise  :database_authenticatable,
          :recoverable,
          :rememberable,
          :timeoutable,
          :trackable,
          :validatable,
          :lockable

  accepts_roles :caseworker, :manager, :admin

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[\w-]{1,10}\z/ }
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?

  scope :by_name, -> { order(:last_name, :first_name) }

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

  # overide devise method to enable login via email OR username
  # see https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#overwrite-devises-find_for_database_authentication-method-in-user-model
  # for details
  #
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h)
        .find_by('lower(username) = :login OR lower(email) = :login', login: login.downcase)
    elsif conditions.key?(:username) || conditions.key?(:email)
      find_by(conditions.to_h)
    end
  end
end
