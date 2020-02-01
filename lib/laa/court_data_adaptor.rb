# frozen_string_literal: true

require 'laa/court_data_adaptor/version'
require 'laa/court_data_adaptor/configuration'
require 'laa/court_data_adaptor/raise_error'
require 'laa/court_data_adaptor/connection'
require 'laa/court_data_adaptor/prosecution_case'
require 'laa/court_data_adaptor/client'

module LAA
  module CourtDataAdaptor
    class << self
      def client
        Client.new
      end

      attr_writer :configuration
      def configuration
        @configuration ||= Configuration.new
      end
      alias config configuration

      def configure
        yield(configuration) if block_given?
        configuration
      end

      def reset
        @configuration = Configuration.new
      end
    end
  end
end
