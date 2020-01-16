# frozen_string_literal: true

# helpers for seeding the database
#
module SeedHelper
  # find_or_create_by does not work with devise user model
  def self.find_or_create_user(attributes)
    user = User.find_by(email: attributes[:email].downcase)
    user = User.create(attributes) if user.blank?

    return user if user.valid?
    user.errors
  end
end
