# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant

      property :title, type: :string
      property :plea, type: :string
      property :plea_date, type: :string
      property :mode_of_trial, type: :string
      property :mode_of_trial_reason, type: :string

      def plea_and_date
        return if plea.nil?
        "#{plea&.humanize} on #{plea_date&.to_date&.strftime('%d/%m/%Y')}"
      end
    end
  end
end
