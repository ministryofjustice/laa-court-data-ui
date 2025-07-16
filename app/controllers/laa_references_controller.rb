# frozen_string_literal: true

require_dependency 'court_data_adaptor'
require_dependency 'feature_flag'

class LaaReferencesController < ApplicationController
  before_action :load_and_authorize_defendant,
                :set_defendant_uuid_if_required,
                :set_defendant_if_required,
                :set_prosecution_case_reference_if_required,
                :set_link_attempt

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) },
                 proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) }
  add_breadcrumb proc { |v| v.controller.defendant.name },
                 proc { |v| v.defendant_path(v.controller.defendant.id) }

  def new
    return unless params.fetch(:include_offence_history, 'false') == 'true'

    @offence_history_collection = Cda::OffenceHistoryCollection.find_from_id_and_urn(
      laa_reference_params[:id],
      laa_reference_params[:urn]
    )
  end

  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')

    @link_attempt.validate!

    CourtDataAdaptor::Query::LinkDefendant.call(resource_params)

    redirect_to edit_defendant_path(defendant.id, urn: prosecution_case_reference),
                notice: I18n.t('laa_reference.link.success')
  rescue CourtDataAdaptor::Errors::Error => e
    handle_link_failure(e.message, e)
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    nil
  ensure
    render 'new' unless performed?
  end

  def defendant_uuid
    @defendant_uuid ||= laa_reference_params[:id] || link_attempt_params[:defendant_id]
  end

  attr_reader :defendant

  def prosecution_case_reference
    @prosecution_case_reference ||= laa_reference_params[:urn]
  end

  private

  def handle_link_failure(message, exception = nil)
    logger.warn "LINK DEFENDANT FAILURE (params: #{@link_attempt.as_json}): #{message}"
    @link_attempt.errors.add(:maat_reference,
                             cda_error_string(exception) || t('cda_errors.internal_server_error'))
  end

  def set_defendant_uuid_if_required
    defendant_uuid
  end

  def set_defendant_if_required
    defendant
  end

  def set_prosecution_case_reference_if_required
    prosecution_case_reference
  end

  def load_and_authorize_defendant
    @defendant = Cda::Defendant.find_from_id_and_urn(defendant_id,
                                                     laa_reference_params[:urn])

    authorize! :show, @defendant
  end

  def laa_reference_params
    params.permit(:id,
                  :urn,
                  link_attempt: %i[maat_reference defendant_id])
  end

  def link_attempt_params
    return unless laa_reference_params[:link_attempt]

    laa_reference_params[:link_attempt].merge(no_maat_id: no_maat_id?,
                                              username: current_user.username)
  end

  def resource_params
    @resource_params ||= @link_attempt.to_link_attributes
  end

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def set_link_attempt
    @link_attempt = if link_attempt_params
                      LinkAttempt.new(link_attempt_params)
                    else
                      LinkAttempt.new
                    end
  end

  def defendant_id
    laa_reference_params[:id] || laa_reference_params.dig(:link_attempt, :defendant_id)
  end
end
