# frozen_string_literal: true

require 'addressable/uri'

module LAA
  module CourtDataAdaptor
    class Client
      extend Forwardable

      attr_reader :connection
      alias conn connection

      def_delegators :connection, :host, :url_prefix, :port, :get

      def initialize
        @connection = Connection.instance
      end

      def prosecution_case
        [
          ProsecutionCase.new('Fred', 'Blogs', '05PP1000915', '1987-05-21', nil),
          ProsecutionCase.new('Bob', 'Blogs', '05PP1000915', '1965-05-21', nil)
        ]
      end
    end
  end
end
