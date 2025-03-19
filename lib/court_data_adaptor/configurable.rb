# frozen_string_literal: true

module CourtDataAdaptor
  module Configurable
    def self.included(base)
      base.include InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      delegate :configuration, to: :class
      alias config configuration
    end

    module ClassMethods
      delegate :configuration, to: :CourtDataAdaptor
      alias config configuration
    end
  end
end
