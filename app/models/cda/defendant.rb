# frozen_string_literal: true

module Cda
  class Defendant < BaseModel
    def self.find_from_id_and_urn(defendant_id, urn)
      find(:one, from: "/api/internal/v2/prosecution_cases/#{urn}/defendants/#{defendant_id}")
    end
  end
end
