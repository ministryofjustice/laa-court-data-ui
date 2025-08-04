module Cda
  class CourtApplicationLaaReference < BaseModel
    self.element_name = "court_application_laa_reference"

    def self.create!(link_attempt)
      court_application_laa_reference = {
        maat_reference: link_attempt.maat_reference,
        subject_id: link_attempt.defendant_id,
        user_name: link_attempt.username
      }
      post('', nil, { court_application_laa_reference: }.to_json)
    end

    def self.update!(unlink_attempt)
      laa_reference = {
        subject_id: unlink_attempt.defendant_id,
        user_name: unlink_attempt.username,
        unlink_reason_code: unlink_attempt.reason_code,
        unlink_other_reason_text: (unlink_attempt.other_reason_text if unlink_attempt.text_required?),
        maat_reference: unlink_attempt.maat_reference
      }
      patch(unlink_attempt.defendant_id, nil, { laa_reference: }.to_json)
    end
  end
end
