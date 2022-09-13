# frozen_string_literal: true

# Custom application rspec helpers can/should
# be added here.
#
module Application
  module Helpers
    def fixture_file(file, options = {})
      base_path = %w[spec fixtures]
      path = base_path.append(options[:relative_path]).append(file).compact
      Rails.root.join(*path).read
    end

    def with_env(env)
      @original_env = ENV.fetch('ENV', nil)
      ENV['ENV'] = env
      yield
    ensure
      ENV['ENV'] = @original_env
    end
  end
end

RSpec.configure do |c|
  c.include Application::Helpers
end
