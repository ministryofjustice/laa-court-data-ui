# frozen_string_literal: true

module DefendantHelper
  def defendant_link_path(defendant, prosecution_case_reference = nil)
    # Dots in the URN are blocked by ModSecurity (403); percent-encode them
    defendant_path(id: defendant.id, urn: prosecution_case_reference).gsub(".", "%2E")
  end

  def linking_enabled?
    !FeatureFlag.enabled?(:no_linking)
  end
end
