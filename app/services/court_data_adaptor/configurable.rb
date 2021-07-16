# frozen_string_literal: true

module CourtDataAdaptor
  module Configurable
    def self.included(base)
      base.include InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def configuration
        self.class.configuration
      end
      alias config configuration
    end

    module ClassMethods
      def configuration
        CourtDataAdaptor.configuration
      end
      alias config configuration
    end
  end
end
