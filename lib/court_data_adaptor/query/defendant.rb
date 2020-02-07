# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Defendant < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        results = term.split(' ').each_with_object([]) do |aterm, arr|
          arr.append(resource.where(first_name: aterm, last_name: aterm).all)
        end
        results.flatten.uniq(&:id)
      end
    end
  end
end
