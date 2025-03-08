# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActiveResource::Base.logger = ActiveRecord::Base.logger
