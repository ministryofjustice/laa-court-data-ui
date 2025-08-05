# frozen_string_literal: true

require_dependency 'feature_flag'

class DefendantsController < ApplicationController
  before_action :load_and_authorize_defendant
  before_action :set_unlink_reasons,
                :set_unlink_attempt,
                :set_defendant_if_required,
                :set_prosecution_case_reference_if_required

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) },
                 proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) }
  add_breadcrumb proc { |v| v.controller.defendant.name },
                 proc { |v| v.defendant_path(v.controller.defendant.id) }

  def edit
    return unless params.fetch(:include_offence_history, 'false') == 'true'

    @offence_history_collection = load_offence_histories
  end

  def offences
    @offence_history_collection = load_offence_histories
    @offence_ids = params[:offence_ids]&.split(',')
    render :offences, layout: false
  end

  def update
    @unlink_attempt.validate!

    logger.info 'CALLING_V2_MAAT_UNLINK'
    Cda::ProsecutionCaseLaaReference.update!(resource_params)

    flash[:notice] = I18n.t('defendants.unlink.success')
    redirect_to new_laa_reference_path(id: defendant.id, urn: prosecution_case_reference)
  rescue ActiveResource::ConnectionError => e
    handle_unlink_failure(e.message, e)
    render 'edit'
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    render 'edit'
  end

  def prosecution_case_reference
    @prosecution_case_reference ||= defendant_params[:urn]
  end

  attr_reader :defendant

  private

  def handle_unlink_failure(message, exception = nil)
    logger.warn "UNLINK DEFENDANT FAILURE (params: #{@unlink_attempt.as_json}): #{message}"
    @unlink_attempt.errors.add(:base,
                               cda_error_string(exception) || t('cda_errors.internal_server_error'))
  end

  def set_defendant_if_required
    defendant
  end

  def set_prosecution_case_reference_if_required
    prosecution_case_reference
  end

  def load_and_authorize_defendant
    @defendant = Cda::Defendant.find_from_id_and_urn(defendant_params[:id], defendant_params[:urn])
    authorize! :show, @defendant
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
      attrs[:maat_reference] = defendant.maat_reference
      attrs[:reason_code] = attrs[:reason_code].to_i
      attrs[:reason_code] = nil if attrs[:reason_code].zero?
    end
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

  def load_offence_histories
    Cda::OffenceHistoryCollection.find_from_id_and_urn(defendant_params[:id], defendant_params[:urn])
  end
end
