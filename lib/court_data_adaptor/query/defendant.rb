# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Defendant < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        refresh_token_if_required!

        cases = resource
                .includes(:defendants)
                .where(
                  first_name: first_name,
                  last_name: last_name,
                  date_of_birth: date_of_birth
                )
                .all

        matching_defendants(cases)
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

      def matching_defendants(cases)
        cases.each_with_object([]) do |c, results|
          c.defendants.each do |d|
            d.prosecution_case_reference = c.prosecution_case_reference
            if d.first_name.casecmp(first_name).zero? && d.last_name.casecmp(last_name).zero?
              results << d
            end
          end
        end
      end
    end
  end
end
