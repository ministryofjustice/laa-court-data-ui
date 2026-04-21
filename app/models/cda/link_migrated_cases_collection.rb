# frozen_string_literal: true

module Cda
  class LinkMigratedCasesCollection < BaseModel
    PATH = "/api/internal/v2/link_migrated_cases"

    def self.fetch(params = {})
      query = params.compact.to_query
      path = query.present? ? "#{PATH}?#{query}" : PATH
      JSON.parse(connection.get(path, headers).body)
    end
  end
end
