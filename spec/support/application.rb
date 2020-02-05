# frozen_string_literal: true

# Custom application rspec helpers can/should
# be added here.
#
module Application
  module Helpers
    def fixture_file(file, options = {})
      base_path = ['spec', 'fixtures']
      path = base_path.append(options[:relative_path]).append(file).compact
      File.read(
        Rails.root.join(*path)
      )
    end

    def prosecution_cases_fixture(file, options = {})
      fixture_file(file, relative_path: 'prosecution_cases')
    end
  end
end

RSpec.configure do |c|
  c.include Application::Helpers
end
