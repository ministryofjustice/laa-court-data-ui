# frozen_string_literal: true

class DefendantFinder < ApplicationService
  def initialize(defendant_id:, connection: Connection.call)
    super
    @defendant_id = defendant_id
    @connection = connection
  end

  def call
    url = "defendants/#{defendant_id}?include=offences"
    response = connection.get(url) if connection.present?
    response.body
  end

  private

  attr_reader :connection, :defendant_id
end
