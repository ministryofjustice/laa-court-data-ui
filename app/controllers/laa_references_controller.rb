# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')
    if link_laa_reference
      flash[:notice] = I18n.t('laa_reference.linking.success')
    else
      flash[:alert] = I18n.t('laa_reference.linking.failure', error_messages: error_messages)
    end
    redirect_to defendant_path(laa_reference_params[:id])
  end

  private

  def link_laa_reference
    laa_reference = resource.new(**resource_params)
    laa_reference.save
  rescue CourtDataAdaptor::Resource::BadRequest => e
    @errors = e.errors
    false
  end

  def laa_reference_params
    params.permit(
      :id,
      :defendant_id,
      :maat_reference
    )
  end

  def resource
    CourtDataAdaptor::Resource::LaaReference
  end

  def resource_params
    @resource_params ||= laa_reference_params.select! { |k, _v| k.in? %w[maat_reference defendant_id] }
  end

  def error_messages
    @errors.map { |k, v| "#{k} #{v.join(', ')}" }.join("\n")
  end
end
