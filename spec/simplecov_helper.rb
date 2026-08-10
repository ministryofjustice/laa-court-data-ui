# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.configure do
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    SimpleCov::Formatter::JSONFormatter
                                                                  ])

  skip '_spec.rb'
  skip 'spec/'
  skip 'config/'
  skip 'db/seeds'
  skip %r{^/factories/}
  skip 'bin/'
  skip 'lib/tasks'
  skip 'rakefile'

  # exclude individual files/dirs from test coverage stats
  skip 'app/controllers/users/confirmations_controller'

  # group functionality for test coverage report
  group 'Models', 'app/models'
  group 'Mailers', '/app/mailers'
  group 'Helpers', 'app/helpers'
end
