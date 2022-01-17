# frozen_string_literal: true

require_dependency 'court_data_adaptor'

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
  rescue_from JsonApiClient::Errors::InternalServerError, with: :adaptor_error_handler

  def edit; end

  def update
    unlink_and_redirect && return if @unlink_attempt.valid?
    render 'edit'
  end

  def unlink_and_redirect
    defendant.update(@unlink_attempt.to_unlink_attributes)

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
    @defendant_search = CourtDataAdaptor::Query::Defendant::ByUuid.new(defendant_params[:id])
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
      attrs[:reason_code] = attrs[:reason_code].to_i
      attrs[:reason_code] = nil if attrs[:reason_code].zero?
    end
  end

  def error_messages
    @errors.map { |k, v| "#{k.to_s.humanize} #{v.join(', ')}" }.join("\n")
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

  def adaptor_error_handler(exception)
    @errors = exception.errors
    flash.now[:alert] = I18n.t('defendants.unlink.failure', error_messages: error_messages)
    render 'edit'
  end
end
