# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Provider < Base
      acts_as_resource self

      belongs_to :hearing

      property :name, type: :string
      property :role, type: :string
    end
  end
end
