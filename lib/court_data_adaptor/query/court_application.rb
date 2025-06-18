module CourtDataAdaptor
  module Query
    class CourtApplication < Base
      acts_as_resource CourtDataAdaptor::Resource::ApplicationSummary

      def make_request
        resource.find(term).first
      end
    end
  end
end
