# frozen_string_literal: true

module LAA
  module CourtDataAdaptor
    class Configuration
      HOST = 'https://laa-court-data-adaptor.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1'
      HEADERS = { 'Accept' => 'application/vnd.api+json', 'User-Agent' => USER_AGENT }.freeze

      attr_accessor :host, :headers

      def initialize
        @host = host || HOST
        @headers = headers || HEADERS
      end
    end
  end
end
