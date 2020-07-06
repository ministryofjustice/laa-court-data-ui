# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  before_action :load_and_authorize_search
  before_action :set_defendant_if_required

  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')
    set_link_attempt
    if @link_attempt.valid?
      if link_laa_reference
        flash[:notice] = I18n.t('laa_reference.link.success')
      else
        flash[:alert] = I18n.t('laa_reference.link.failure', error_messages: error_messages)
      end
      redirect_to edit_defendant_path(laa_reference_params[:id])
    else
      render 'defendants/edit'
    end
  end

  def defendant
    @defendant ||= @search.execute.first
  end

  private

  def link_laa_reference
    resource_params.delete(:maat_reference) if no_maat_id?
    laa_reference = resource.new(**resource_params)
    laa_reference.save
  rescue CourtDataAdaptor::Errors::BadRequest => e
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

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def error_messages
    @errors.map { |k, v| "#{k.humanize} #{v.join(', ')}" }.join("\n")
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: laa_reference_params[:id])
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def link_attempt_attributes
    laa_reference_params.except(:defendant_id).merge(no_maat_id: no_maat_id?)
  end

  def set_link_attempt
    @link_attempt = if link_attempt_attributes
                      LinkAttempt.new(link_attempt_attributes)
                    else
                      LinkAttempt.new
                    end
  end
end
