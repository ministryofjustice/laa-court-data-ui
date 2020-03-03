# frozen_string_literal: true

module CourtDataAdaptor
  class Configuration
    attr_accessor :api_url, :api_uid, :api_secret, :test_mode

    def initialize(options = {})
      @api_url = options.fetch(:api_url, nil)
      @api_uid = options.fetch(:api_uid, nil)
      @api_secret = options.fetch(:api_secret, nil)
      @test_mode = options.fetch(:test_mode, false)
    end

    def test_mode?
      test_mode.eql?(true)
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end
  end
end
