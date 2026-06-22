# frozen_string_literal: true

require_dependency 'feature_flag'

class DefendantsController < ApplicationController
  before_action :load_and_authorize_defendant
  before_action :set_breadcrumbs

  # GET /defendants/:id?urn=:urn
  # Defendant detail page: defendant info + offences. Links out to link/unlink. No form.
  def show
    return unless params.fetch(:include_offence_history, 'false') == 'true'

    @offence_history_collection = load_offence_histories
  end

  # GET /defendants/:id/offences?urn=:urn
  # Offences table fragment rendered without layout (used by Turbo Frame).
  def offences
    @offence_history_collection = load_offence_histories
    @offence_ids = params[:offence_ids]&.split(',')
    render :offences, layout: false
  end

  # GET /defendants/:id/link?urn=:urn
  def show_link
    @form_model = load_link_attempt
  end

  # GET /defendants/:id/unlink?urn=:urn
  def show_unlink
    @form_model = load_unlink_attempt
  end

  # POST /defendants/:id/link?urn=:urn
  def link
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')

    @form_model = load_link_attempt
    validate_link_attempt!

    Cda::ProsecutionCaseLaaReference.create!(@form_model.to_link_attributes)

    redirect_to defendant_path(defendant.id, urn: prosecution_case_reference),
                notice: I18n.t('laa_reference.link.success')
  rescue ActiveResource::ConnectionError => e
    handle_link_failure(e.message, e)
    render :show_link
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    render :show_link
  end

  # POST /defendants/:id/unlink?urn=:urn
  def unlink
    @form_model = load_unlink_attempt
    @form_model.validate!

    logger.info 'CALLING_V2_MAAT_UNLINK'
    Cda::ProsecutionCaseLaaReference.update!(@form_model.to_unlink_attributes)

    redirect_to defendant_path(defendant.id, urn: prosecution_case_reference),
                notice: I18n.t('defendants.unlink.success')
  rescue ActiveResource::ConnectionError => e
    handle_unlink_failure(e.message, e)
    render :show_unlink
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    render :show_unlink
  end

  attr_reader :defendant

  def prosecution_case_reference
    @prosecution_case_reference ||= params[:urn]
  end

  private

  def load_and_authorize_defendant
    @defendant = Cda::Defendant.find_from_id_and_urn(params[:id], prosecution_case_reference)
    authorize! :show, @defendant
  end

  def set_breadcrumbs
    add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
    add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
    add_breadcrumb prosecution_case_name(prosecution_case_reference),
                   prosecution_case_path(prosecution_case_reference)
    add_breadcrumb defendant.name, defendant_path(defendant.id, urn: prosecution_case_reference)

    add_breadcrumb 'Link' if action_name.in?(%w[show_link link])
    add_breadcrumb 'Unlink' if action_name.in?(%w[show_unlink unlink])
  end

  def validate_link_attempt!
    if params[:maat_ref_required] == 'true'
      @form_model.validate!(:maat_ref_required)
    else
      @form_model.maat_reference = nil
      @form_model.validate!
    end
  end

  def load_link_attempt
    LinkAttempt.new(
      defendant_id: defendant.id,
      username: current_user.username,
      maat_reference: params.dig(:link_attempt, :maat_reference)
    )
  end

  def load_unlink_attempt
    reason_code = params.dig(:unlink_attempt, :reason_code).to_i
    reason_code = nil if reason_code.zero?

    UnlinkAttempt.new(
      defendant_id: defendant.id,
      username: current_user.username,
      reason_code:,
      other_reason_text: params.dig(:unlink_attempt, :other_reason_text),
      maat_reference: defendant.maat_reference
    )
  end

  def handle_link_failure(message, exception = nil)
    logger.warn "LINK DEFENDANT FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:maat_reference,
                           cda_error_string(exception) || t('cda_errors.internal_server_error'))
  end

  def handle_unlink_failure(message, exception = nil)
    logger.warn "UNLINK DEFENDANT FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:base,
                           cda_error_string(exception) || t('cda_errors.internal_server_error'))
  end

  def load_offence_histories
    Cda::OffenceHistoryCollection.find_from_id_and_urn(params[:id], prosecution_case_reference)
  end
end
