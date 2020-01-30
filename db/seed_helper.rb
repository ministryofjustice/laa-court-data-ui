# frozen_string_literal: true

# helpers for seeding the database
#
module SeedHelper
  # find_or_create_by does not work with devise user model
  def self.find_or_create_user(attributes)
    email = attributes[:email].downcase
    user = User.find_by(email: email)
    if user.blank?
      attributes[:email_confirmation] = email
      user = User.create(attributes) if user.blank?
    end

    return user if user.valid?
    user.errors
  end
end
