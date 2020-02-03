# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      VERSION = '0.0.1'
      self.site = 'https://laa-court-data-adaptor.apps.live-1.cloud-platform.service.justice.gov.uk/api/v1'
    end
  end
end
