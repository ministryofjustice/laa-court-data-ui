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
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaCourtDataUi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

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

    config.action_dispatch.signed_cookie_digest = 'SHA256'
    config.exceptions_app = routes
    config.active_job.queue_adapter = :sidekiq
    config.x.support_email_address = 'access-court-data-team@digital.justice.gov.uk'
    config.x.display_raw_responses = %w[enabled true].include?(ENV.fetch('DISPLAY_RAW_RESPONSES', nil))
    config.action_mailer.deliver_later_queue_name = :mailers
    config.x.court_data_api_config.uri = ENV.fetch('COURT_DATA_API_URL', nil)
    config.x.court_data_api_config.user = ENV.fetch('COURT_DATA_API_USERNAME', nil)
    config.x.court_data_api_config.secret = ENV.fetch('COURT_DATA_API_SECRET', nil)
  end
end
