# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  before_action :set_defendant_identifier_if_required,
                :load_and_authorize_search,
                :set_defendant_if_required

  def new
    @link_attempt = LinkAttempt.new
  end

  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')

    @link_attempt = LinkAttempt.new link_attempt_params
    if @link_attempt.valid?
      if link_laa_reference
        flash[:notice] = I18n.t('laa_reference.link.success')
        redirect_to edit_defendant_path(link_attempt_params[:defendant_identifier])
      else
        flash[:alert] = I18n.t('laa_reference.link.failure', error_messages: error_messages)
      end
    else
      render 'laa_references/new'
    end
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
      link_attempt: %i[id defendant_id maat_reference defendant_identifier]
    )
  end

  def link_attempt_params
    laa_reference_params[:link_attempt].merge(no_maat_id: no_maat_id?)
  end

  def defendant_identifier
    @defendant_identifier = laa_reference_params[:id] || link_attempt_params[:defendant_identifier]
  end

  def resource
    CourtDataAdaptor::Resource::LaaReference
  end

  def resource_params
    @resource_params ||= link_attempt_params.select! { |k, _v| k.in? %w[maat_reference defendant_id] }
  end

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def error_messages
    @errors.map { |k, v| "#{k.humanize} #{v.join(', ')}" }.join("\n")
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: @defendant_identifier)
    authorize! :create, @search
  end

  def defendant
    @defendant ||= @search.execute.first
  end

  def set_defendant_if_required
    defendant
  end

  def set_defendant_identifier_if_required
    defendant_identifier
  end
end
