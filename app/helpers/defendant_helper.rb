# frozen_string_literal: true

module DefendantHelper
  def defendant_link_path(defendant, prosecution_case_reference = nil)
    defendant_path(id: defendant.id, urn: prosecution_case_reference)
  end

  def linking_enabled?
    !FeatureFlag.enabled?(:no_linking)
  end
end
