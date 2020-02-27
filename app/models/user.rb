# frozen_string_literal: true

class User < ApplicationRecord
  include Roles

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable,
          # :registerable,
          :recoverable,
          :rememberable,
          :timeoutable,
          :trackable,
          :validatable,
          :lockable

  accepts_roles :caseworker, :manager, :admin

  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?

  def name
    "#{first_name} #{last_name}"
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
