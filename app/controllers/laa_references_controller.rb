# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  # link
  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')
    @laa_reference = link_laa_reference(laa_reference_params)
    flash[:notice] = "TODO: MAAT ID #{laa_reference_params[:maat_reference]} linked"
    redirect_to defendant_path(laa_reference_params[:id])
  end

  private

  def link_laa_reference(options)
    # TODO: query and update
    # resource = CourtDataAdaptor::Resource::LaaReferences
    # resource.find().update_attributes
  end

  def laa_reference_params
    params.permit(
      :id,
      :defendant_id,
      :maat_reference
    )
  end
end
