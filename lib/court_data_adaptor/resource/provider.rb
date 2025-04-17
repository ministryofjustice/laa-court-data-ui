# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Provider < V1
      acts_as_resource self

      belongs_to :hearing

      property :name, type: :string
      property :role, type: :string
    end
  end
end
