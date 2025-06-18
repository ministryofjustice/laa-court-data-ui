module CourtDataAdaptor
  module Query
    class UnlinkDefendant < Base
      acts_as_resource CourtDataAdaptor::Resource::LaaReference

      alias params term

      def make_request
        resource.connection.faraday.patch(
          "laa_references/#{params[:defendant_id]}", laa_reference: params
        )
      end
    end
  end
end
