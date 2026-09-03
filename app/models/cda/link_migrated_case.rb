# frozen_string_literal: true

module Cda
  class LinkMigratedCase < BaseModel
    class << self
      def find_from_id(id)
        find(:one, from: "/api/internal/v2/link_migrated_cases/#{safe_path(id)}")
      end

      def create!(params)
        laa_reference = {
          maat_reference: params[:maat_reference],
          defendant_id: params[:defendant_id],
          user_name: params[:user_name],
          id: params[:id],
        }
        post("", nil, { laa_reference: }.to_json)
      end
    end
  end
end
