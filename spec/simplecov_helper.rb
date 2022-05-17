# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.configure do
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    SimpleCov::Formatter::JSONFormatter
                                                                  ])
    
  add_filter '_spec.rb'
  add_filter 'spec/'
  add_filter 'config/'
  add_filter 'db/seeds'
  add_filter %r{^/factories/}
  add_filter 'bin/'
  add_filter 'lib/tasks'
  add_filter 'rakefile'

  # exclude individual files/dirs from test coverage stats
  add_filter 'app/controllers/users/confirmations_controller'

  # group functionality for test coverage report
  add_group 'Models', 'app/models'
  add_group 'Mailers', '/app/mailers'
  add_group 'Helpers', 'app/helpers'
end
