# frozen_string_literal: true

class LaaReferencesController < ApplicationController
  before_action :set_defendant_uuid_if_required,
                :authorize_defendant_search,
                :set_link_attempt,
                :set_defendant_if_required

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.defendant.id) }),
                 (proc { |v| v.prosecution_case_path(v.controller.defendant.id) })

  def new
    add_breadcrumb defendant.name,
                   defendant_path(defendant.id)
  end

  # rubocop:disable Metrics/AbcSize
  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')

    if @link_attempt.valid?
      if link_laa_reference
        redirect_to edit_defendant_path(id: defendant.id)
        flash[:notice] = I18n.t('laa_reference.link.success')
      else
        redirect_to new_laa_reference_path(id: defendant.id)
        flash[:alert] = I18n.t('laa_reference.link.failure', error_messages: error_messages)
      end
    else
      render 'new'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def defendant
    @defendant ||= @defendant_search.find(@defendant_uuid).first
  end

  private

  def set_defendant_if_required
    defendant
  end

  def defendant_resource
    CourtDataAdaptor::Resource::Defendant
  end

  def authorize_defendant_search
    @defendant_search = defendant_resource
    authorize! :show, @defendant_search
  end

  def link_laa_reference
    resource_params.delete(:maat_reference) if no_maat_id?
    laa_reference = resource.new(**resource_params)
    laa_reference.save
  rescue CourtDataAdaptor::Errors::BadRequest => e
    @errors = e.errors
    false
  end

  def laa_reference_params
    params.permit(:id,
                  link_attempt: %i[maat_reference defendant_id])
  end

  def link_attempt_params
    return unless laa_reference_params[:link_attempt]

    laa_reference_params[:link_attempt].merge(no_maat_id: no_maat_id?)
  end

  def defendant_uuid
    @defendant_uuid ||= laa_reference_params[:id] || link_attempt_params[:defendant_id]
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

  def set_defendant_uuid_if_required
    defendant_uuid
  end

  def set_link_attempt
    @link_attempt = if link_attempt_params
                      LinkAttempt.new(link_attempt_params)
                    else
                      LinkAttempt.new
                    end
  end
end
