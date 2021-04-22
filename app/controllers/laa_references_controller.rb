# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class LaaReferencesController < ApplicationController
  before_action :load_and_authorize_defendant_search,
                :set_defendant_uuid_if_required,
                :set_defendant_if_required,
                :set_prosecution_case_reference_if_required,
                :set_link_attempt,
                :set_unlink_reasons,
                :set_unlink_attempt

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) })
  add_breadcrumb (proc { |v| v.controller.defendant.name }),
                 (proc { |v|
                    v.laa_reference_path(v.controller.defendant.id, v.controller.prosecution_case_reference)
                  })

  rescue_from CourtDataAdaptor::Errors::BadRequest, with: :adaptor_error_handler

  def new; end

  def show; end

  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')

    link_laa_reference_and_redirect && return if @link_attempt.valid?
    render 'new'
  end

  def destroy
    unlink_and_redirect && return if @unlink_attempt.valid?
    render 'show'
  end

  def defendant_uuid
    @defendant_uuid ||= laa_reference_params[:id] || link_attempt_params[:defendant_id]
  end

  def defendant
    @defendant ||= @defendant_search.call
  end

  def prosecution_case_reference
    @prosecution_case_reference ||= laa_reference_params[:urn]
  end

  private

  def set_defendant_uuid_if_required
    defendant_uuid
  end

  def set_defendant_if_required
    defendant
  end

  def set_prosecution_case_reference_if_required
    prosecution_case_reference
  end

  def load_and_authorize_defendant_search
    @defendant_search = CourtDataAdaptor::Query::Defendant::ByUuid.new(defendant_uuid)
    authorize! :show, @defendant_search
  end

  def link_laa_reference_and_redirect
    laa_reference = resource.new(**resource_params)
    laa_reference.save

    redirect_to laa_reference_path(defendant.id, urn: prosecution_case_reference)
    flash[:notice] = I18n.t('laa_reference.link.success')
  end

  def unlink_and_redirect
    defendant.update(@unlink_attempt.to_unlink_attributes)
    # TODO: this needs to be be a call to the new DELETE endpoint
    # something like laa_reference.destroy

    redirect_to new_laa_reference_path(id: defendant.id, urn: prosecution_case_reference)
    flash[:notice] = I18n.t('defendants.unlink.success')
  end

  def laa_reference_params
    params.permit(:id,
                  :urn,
                  link_attempt: %i[maat_reference defendant_id],
                  unlink_attempt: %i[reason_code other_reason_text])
  end

  def link_attempt_params
    return unless laa_reference_params[:link_attempt]

    laa_reference_params[:link_attempt].merge(no_maat_id: no_maat_id?,
                                              username: current_user.username)
  end

  def unlink_attempt_params
    return unless laa_reference_params[:unlink_attempt]

    laa_reference_params[:unlink_attempt]
  end

  def resource
    CourtDataAdaptor::Resource::LaaReference
  end

  def resource_params
    @resource_params ||= @link_attempt.to_link_attributes
  end

  def unlink_resource_params
    @unlink_resource_params ||= @unlink_attempt.to_unlink_attributes
  end

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def error_messages
    @errors.map { |k, v| "#{k.humanize} #{v.join(', ')}" }.join("\n")
  end

  def set_link_attempt
    @link_attempt = if link_attempt_params
                      LinkAttempt.new(link_attempt_params)
                    else
                      LinkAttempt.new
                    end
  end

  def set_unlink_attempt
    @unlink_attempt = if unlink_attempt_attributes
                        UnlinkAttempt.new(unlink_attempt_attributes)
                      else
                        UnlinkAttempt.new
                      end
  end

  def unlink_attempt_attributes
    return unless unlink_attempt_params

    # reason code must be an integer from 1..7
    unlink_attempt_params.merge(username: current_user.username).tap do |attrs|
      attrs[:reason_code] = attrs[:reason_code].to_i
      attrs[:reason_code] = nil if attrs[:reason_code].zero?
    end
  end

  def adaptor_error_handler(exception)
    @errors = exception.errors
    flash.now[:alert] = I18n.t('laa_reference.link.failure', error_messages: error_messages)
    render 'new'
  end

  def set_unlink_reasons
    @unlink_reasons = UnlinkReason.all
  end
end
