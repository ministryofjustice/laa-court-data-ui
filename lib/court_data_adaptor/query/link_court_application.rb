module CourtDataAdaptor
  module Query
    class LinkCourtApplication < Base
      acts_as_resource CourtDataAdaptor::Resource::ApplicationSummary

      alias link_params term

      def make_request
        refresh_token_if_required!

        response = resource.connection.faraday.post "court_application_laa_references", laa_reference: {
          maat_reference: link_params.maat_reference,
          subject_id: link_params.defendant_id,
          user_name: link_params.username
        }

        response.status.in?(200..299)
      end
    end
  end
end
