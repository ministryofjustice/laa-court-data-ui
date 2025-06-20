module CourtDataAdaptor
  module Query
    class LinkDefendant < Base
      acts_as_resource CourtDataAdaptor::Resource::LaaReference

      alias params term

      def make_request
        resource.connection.faraday.post "laa_references", laa_reference: params
      end
    end
  end
end
