# frozen_string_literal: true

class User < ApplicationRecord
  include Roles
  extend ArrayEnum

  # FEATURE_FLAGS = ["view_appeals"].freeze
  # array_enum feature_flags: FEATURE_FLAGS.to_h { [it, it] }

  # Include default devise modules. Others available are:
  # :confirmable, :registerable and :omniauthable
  devise  :omniauthable,
          :timeoutable,
          :trackable,
          :lockable,
          :validatable

  accepts_roles :caseworker, :manager, :admin, :data_analyst

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A[\w-]{1,10}\z/ }
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?

  scope :by_name, -> { order(:first_name, :last_name) }

  attr_writer :login

  def login
    @login || username || email
  end

  def name
    "#{first_name} #{last_name}"
  end

  def feature_flag_enabled?(flag)
    feature_flags.include?(flag.to_s)
  end

  # To enable Devise emails to be delivered in the background.
  # https://github.com/heartcombo/devise#activejob-integration
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
