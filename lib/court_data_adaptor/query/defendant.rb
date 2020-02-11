# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Defendant < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        resource
          .where(
            first_name: first_name,
            last_name: last_name,
            date_of_birth: date_of_birth
          ).all
      end

      private

      def name
        @name ||= NameParser.new(term)
      end

      def first_name
        name.first&.capitalize
      end

      def last_name
        name.last&.capitalize
      end

      def date_of_birth
        Date.parse(dob.to_s).iso8601 if dob
      end
    end
  end
end
