# frozen_string_literal: true

class Connection < ApplicationService
  def initialize(host: CourtDataAdaptor.configuration.api_url)
    super
    @host = host
  end

  def call
    return if host.blank?

    Faraday.new host do |connection|
      connection.request :oauth2, access_token.token, token_type: :bearer
      connection.request :json
      connection.response :json
      connection.adapter Faraday.default_adapter
    end
  end

  private

  def access_token
    @access_token = new_access_token if @access_token.blank? || @access_token.expired?
  end

  def new_access_token
    client.client_credentials.get_token
  end

  def client
    @client ||= OAuth2::Client.new(
      CourtDataAdaptor.configuration.api_uid,
      CourtDataAdaptor.configuration.api_secret,
      site: CourtDataAdaptor.configuration.api_url
    )
  end

  attr_reader :host
end
