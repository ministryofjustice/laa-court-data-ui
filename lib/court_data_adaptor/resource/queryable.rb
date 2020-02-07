# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    module Queryable
      def self.included(base)
        base.include InstanceMethods
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_resource(resource)
          cattr_accessor :resource
          self.resource = resource
        end
      end

      module InstanceMethods
        def resource
          self.class.resource
        end
      end
    end
  end
end
