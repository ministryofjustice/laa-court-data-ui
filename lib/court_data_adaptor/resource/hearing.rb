# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Hearing < Base
      acts_as_resource self

      has_many :providers

      def provider_list
        providers&.map(&:name_and_role) || []
      end
    end
  end
end
