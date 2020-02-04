# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Base < JsonApiClient::Resource
      VERSION = '0.0.1'
      self.site = ENV['COURT_DATA_ADAPTOR_HOST']
    end
  end
end
