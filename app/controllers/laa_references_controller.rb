# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  before_action :set_defendant_asn_if_required,
                :load_and_authorize_search
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
      redirect_to edit_defendant_path(defendant_asn)
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
      :maat_reference,
      link_attempt: %i[id defendant_id maat_reference defendant_asn]
    )
  end

  def resource
    CourtDataAdaptor::Resource::LaaReference
  end

  def resource_params
    @resource_params ||= if link_attempt_params
                           link_attempt_params.select! { |k, _v| k.in? %w[maat_reference defendant_id] }
                         else
                           laa_reference_params.select! { |k, _v| k.in? %w[maat_reference defendant_id] }
                         end
  end

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def error_messages
    @errors.map { |k, v| "#{k.humanize} #{v.join(', ')}" }.join("\n")
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: @defendant_asn)
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def link_attempt_params
    laa_reference_params[:link_attempt]
  end

  def link_attempt_attributes
    if link_attempt_params
      link_attempt_params.merge(no_maat_id: no_maat_id?)
    else
      laa_reference_params.merge(no_maat_id: no_maat_id?)
    end
  end

  def set_link_attempt
    @link_attempt = if link_attempt_attributes
                      LinkAttempt.new(link_attempt_attributes)
                    else
                      LinkAttempt.new
                    end
  end

  def set_defendant_asn_if_required
    defendant_asn
  end

  def defendant_asn
    @defendant_asn ||= laa_reference_params[:id]\
                   || link_attempt_params[:defendant_asn]\
                   || link_attempt_params[:id]
  end
end
