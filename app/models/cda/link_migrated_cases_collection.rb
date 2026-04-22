# frozen_string_literal: true

module Cda
  class LinkMigratedCasesCollection < BaseModel
    def self.fetch(params = {})
      find(:one, from: "/api/internal/v2/link_migrated_cases", params: params.compact).as_json
    end
  end
end
