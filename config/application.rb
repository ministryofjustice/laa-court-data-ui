# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaCourtDataUi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # best practice not to autoload or eagerload 'lib'
    # https://github.com/rails/rails/issues/13142#issuecomment-29744953
    #
    # config.autoload_paths << Rails.root.join('lib')
    # config.eager_load_paths << Rails.root.join('lib')

    config.exceptions_app = routes
    config.active_job.queue_adapter = :sidekiq
    config.x.support_email_address = 'laa-get-paid@digital.justice.gov.uk'
    config.x.display_raw_responses = %w[enabled true].include?(ENV['DISPLAY_RAW_RESPONSES'])
    config.cache_expiry = (ENV['CACHE_TIMEOUT']&.strip || 10.minutes).to_i
  end
end
