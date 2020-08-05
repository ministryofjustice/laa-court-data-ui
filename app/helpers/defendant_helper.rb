# frozen_string_literal: true

module DefendantHelper
  def defendant_link_path(defendant, prosecution_case_reference = nil)
    if defendant.linked?
      edit_defendant_path(id: defendant.id, urn: prosecution_case_reference)
    else
      new_laa_reference_path(id: defendant.id, urn: prosecution_case_reference)
    end
  end
end
