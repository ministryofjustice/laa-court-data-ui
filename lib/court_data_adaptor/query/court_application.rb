module CourtDataAdaptor
  module Query
    class CourtApplication < Base
      acts_as_resource CourtDataAdaptor::Resource::ApplicationSummary

      def call
        refresh_token_if_required!

        resource.find(term).first
      end
    end
  end
end
