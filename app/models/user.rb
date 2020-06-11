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

  before_validation :generate_uuid

  accepts_roles :caseworker, :manager, :admin

  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
  validates :unique_user_reference, uniqueness: true

  def name
    "#{first_name} #{last_name}"
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def generate_uuid
    return if unique_user_reference.present?
    while unique_user_reference.blank?
      ref = SecureRandom.hex(5)
      self.unique_user_reference = ref if User.where(unique_user_reference: ref).blank?
    end
  end
end
