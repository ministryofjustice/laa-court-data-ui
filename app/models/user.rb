# frozen_string_literal: true

class User < ApplicationRecord
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

  def name
    "#{last_name}, #{first_name}"
  end
end
