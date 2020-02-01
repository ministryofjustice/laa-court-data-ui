# frozen_string_literal: true

require 'singleton'
require 'faraday'

module LAA
  module CourtDataAdaptor
    class Connection
      include Singleton
      extend Forwardable

      attr_reader :conn
      def_delegators :conn, :port, :headers, :url_prefix, :options, :ssl, :get

      def initialize
        @conn = Faraday.new(url: config.host, headers: default_headers) do |conn|
          conn.use RaiseError
          conn.adapter Faraday::Adapter::NetHttp
        end
      end

      class << self
        extend SingleForwardable

        def config
          LAA::CourtDataAdaptor.configuration
        end

        def_delegator :config, :host
      end

      def host
        self.class.host
      end

      private

      def config
        self.class.config
      end

      def default_headers
        config.headers
      end
    end
  end
end
