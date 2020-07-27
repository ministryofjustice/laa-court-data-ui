# frozen_string_literal: true

require 'court_data_adaptor'

module DefendantSearchable
  extend ActiveSupport::Concern

  # def defendant
  #   @defendant ||= defendant_resource.find(term).first
  # end

  private

  # def set_defendant_if_required
  #   defendant
  # end

  def term
    @defendant_uuid || defendant_params[:id]
  end

  def defendant_resource
    CourtDataAdaptor::Resource::Defendant
  end
end
