# frozen_string_literal: true

module CourtDataAdaptor
  module ActsAsResource
    def self.included(base)
      base.include InstanceMethods
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_resource(resource)
        cattr_accessor :resource
        self.resource = resource
      end

      def refresh_token_if_required!
        resource.connection(true) do |conn|
          conn.use FaradayMiddleware::OAuth2, resource.client.bearer_token, token_type: :bearer
        end
      end
    end

    module InstanceMethods
      delegate :resource, to: :class

      delegate :refresh_token_if_required!, to: :class
    end
  end
end
