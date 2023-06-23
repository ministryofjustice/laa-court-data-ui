# frozen_string_literal: true

# rubocop:disable Metrics

require_dependency 'court_data_adaptor'
require_dependency 'feature_flag'

class DefendantsController < ApplicationController
  before_action :load_and_authorize_defendant_search
  before_action :set_unlink_reasons,
                :set_unlink_attempt,
                :set_defendant_if_required,
                :set_prosecution_case_reference_if_required

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) })
  add_breadcrumb (proc { |v| v.controller.defendant.name }),
                 (proc { |v| v.defendant_path(v.controller.defendant.id) })

  rescue_from CourtDataAdaptor::Errors::BadRequest, with: :adaptor_error_handler

  def edit; end

  def update
    unlink_laa_reference_and_redirect && return if @unlink_attempt.valid?
    render 'edit'
  end

  def redirect_to_edit_defendants
    redirect_to new_laa_reference_path(id: defendant.id, urn: prosecution_case_reference)
    flash[:notice] = I18n.t('defendants.unlink.success')
  end

  def defendant
    @defendant ||= @defendant_search.call
  end

  def prosecution_case_reference
    @prosecution_case_reference ||= defendant_params[:urn]
  end

  private

  def set_defendant_if_required
    defendant
  end

  def set_prosecution_case_reference_if_required
    prosecution_case_reference
  end

  def load_and_authorize_defendant_search
    if Feature.enabled?(:defendants_page)
      @defendant_search = CdApi::SearchService.new('uuid_reference', { uuid: defendant_params[:id],
                                                                       urn: defendant_params[:urn] }, nil)
    else
      @defendant_search = CourtDataAdaptor::Query::Defendant::ByUuid.new(defendant_params[:id])
    end
    authorize! :show, @defendant_search
  end

  def defendant_params
    params.permit(:id,
                  :urn,
                  unlink_attempt: %i[reason_code other_reason_text])
  end

  def unlink_attempt_params
    defendant_params[:unlink_attempt]
  end

  def unlink_attempt_attributes
    return unless unlink_attempt_params

    # reason code must be an integer from 1..7
    unlink_attempt_params.merge(username: current_user.username).tap do |attrs|
      attrs[:defendant_id] = defendant.id
      attrs[:maat_reference] = defendant.maat_reference.to_i
      attrs[:reason_code] = attrs[:reason_code].to_i
      attrs[:reason_code] = nil if attrs[:reason_code].zero?
    end
  end

  def error_messages
    @errors.map { |k, v| "#{k.to_s.humanize} #{v.join(', ')}" }.join("\n")
  end

  def resource
    logger.info 'USING_V2_ENDPOINT'
    CdApi::LaaReferences
  end

  def resource_save
    logger.info 'CALLING_V2_MAAT_UNLINK'
    unlink
  rescue ActiveResource::ResourceInvalid, ActiveResource::BadRequest => e
    handle_client_error(e)
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    handle_server_error(e)
  else
    redirect_to_edit_defendants
  end

  def handle_client_error(exception)
    logger.info 'CLIENT_ERROR_OCCURRED'
    exception_body_message(exception)
    render_edit(I18n.t('defendants.unlink.unprocessable'), @laa_reference.errors.full_messages.join(', '))
  end

  def handle_server_error(exception)
    logger.error 'SERVER_ERROR_OCCURRED'
    log_sentry_error(exception, exception_body_message(exception))
    render_edit(
      I18n.t('defendants.unlink.failure',
             error_messages: @laa_reference.errors.full_messages.join(', ')), I18n.t('error.it_helpdesk')
    )
  end

  def exception_body_message(exception)
    @laa_reference.errors.from_json(exception.response.body)
  end

  def unlink_laa_reference_and_redirect
    @laa_reference = resource.new(id: resource_params[:defendant_id])
    resource_save
  end

  def unlink
    @laa_reference.patch(nil, nil, resource_params.to_json)
  end

  def set_unlink_reasons
    @unlink_reasons = UnlinkReason.all
  end

  def set_unlink_attempt
    @unlink_attempt = if unlink_attempt_attributes
                        UnlinkAttempt.new(unlink_attempt_attributes)
                      else
                        UnlinkAttempt.new
                      end
  end

  def resource_params
    @resource_params ||= @unlink_attempt.to_unlink_attributes
  end

  def adaptor_error_handler(exception)
    @errors = exception.errors
    flash.now[:alert] = I18n.t('defendants.unlink.failure', error_messages:)
    render 'edit'
  end

  def render_edit(title, message)
    flash.now[:alert] = { title:, message: }
    render 'edit'
  end
end

# rubocop:enable Metrics
