# frozen_string_literal: true

require 'simplecov'

SimpleCov.configure do
  formatter SimpleCov::Formatter::HTMLFormatter

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
