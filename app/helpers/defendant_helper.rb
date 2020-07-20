# frozen_string_literal: true

module DefendantHelper
  def defendant_link_path(defendant)
    if defendant.linked?
      edit_defendant_path(defendant.id)
    else
      new_laa_reference_path(id: defendant.id)
    end
  end
end
