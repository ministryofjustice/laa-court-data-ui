# frozen_string_literal: true

module CustomJsonFormat
  include ActiveResource::Formats::JsonFormat

  extend self

  def decode(json)
    ActiveSupport::JSON.decode(json)['data']['attributes']
  end
end

class BaseModel < ActiveResource::Base
  def self.access_token
    @access_token = new_access_token if @access_token.blank? || @access_token.expired?
  end

  def self.new_access_token
    client.client_credentials.get_token
  end

  def self.client
    @client ||= OAuth2::Client.new(
      CourtDataAdaptor.configuration.api_uid,
      CourtDataAdaptor.configuration.api_secret,
      site: CourtDataAdaptor.configuration.api_url
    )
  end

  self.site = CourtDataAdaptor.configuration.api_url
  headers['authorization'] = 'Bearer ' + access_token.token
  self.format = CustomJsonFormat
end
