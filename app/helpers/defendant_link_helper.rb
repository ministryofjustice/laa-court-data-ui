# frozen_string_literal: true

module DefendantLinkHelper
  def defendant_link_path(defendant)
    if defendant.linked?
      edit_defendant_path(defendant.arrest_summons_number || defendant.national_insurance_number)
    else
      new_laa_reference_path(id: defendant.arrest_summons_number || defendant.national_insurance_number)
    end
  end
end
