# frozen_string_literal: true

module Cda
  class LinkMigratedCase < BaseModel
    def self.find_from_id(id)
      find(:one, from: "/api/internal/v2/link_migrated_cases/#{safe_path(id)}")
    end
  end
end
