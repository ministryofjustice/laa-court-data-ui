module CourtDataAdaptor
  module Query
    class UnlinkCourtApplication < Base
      acts_as_resource CourtDataAdaptor::Resource::ApplicationSummary

      alias unlink_object term

      def call
        refresh_token_if_required!

        response = resource.connection.faraday.patch(
          "court_application_laa_references/#{unlink_object.defendant_id}",
          unlink_params
        )

        response.status.in?(200..299)
      end

      private

      def unlink_params
        {
          laa_reference: {
            subject_id: unlink_object.defendant_id,
            user_name: unlink_object.username,
            unlink_reason_code: unlink_object.reason_code,
            unlink_other_reason_text: (unlink_object.other_reason_text if unlink_object.text_required?)
          }
        }
      end
    end
  end
end
