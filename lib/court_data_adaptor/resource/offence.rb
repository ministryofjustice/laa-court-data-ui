# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant

      property :title, type: :string
      property :pleas, type: :struct_collection, default: []
      property :mode_of_trial_reasons, type: :struct_collection, default: []

      def plea_and_date
        return if plea.nil?
        "#{plea&.humanize} on #{plea_date&.to_date&.strftime('%d/%m/%Y')}"
      end
    end
  end
end
