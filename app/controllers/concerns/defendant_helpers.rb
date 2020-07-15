# frozen_string_literal: true

module DefendantHelpers
  extend ActiveSupport::Concern

  def defendant
    @defendant ||= @search.execute.first
  end

  private

  def defendant_identifier
    defendant.arrest_summons_number || defendant.national_insurance_number
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: term)
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def term
    @defendant_asn_or_nino || defendant_params[:id]
  end

  def add_defendant_case_breadcrumb
    add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.defendant.prosecution_case_reference) }),
                   (proc { |v| v.prosecution_case_path(v.controller.defendant.prosecution_case_reference) })
  end
end
