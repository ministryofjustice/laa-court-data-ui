# frozen_string_literal: true

# helpers for seeding the database
#
module SeedHelper
  # find_or_create_by does not work with devise user model
  def self.find_or_create_user(attributes)
    user = User.find_by(email: attributes[:email].downcase)

    if user.blank?
      user = User.create(
        email: attributes[:email],
        first_name: attributes[:first_name],
        last_name: attributes[:last_name],
        password: attributes[:password],
        password_confirmation: attributes[:password]
      )
    end

    return user if user.valid?
    user.errors
  end
end