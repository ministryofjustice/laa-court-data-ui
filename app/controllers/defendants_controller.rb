# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :load_and_authorize_search
  before_action :set_unlink_reasons, only: :show
  before_action :set_unlink_reason, only: :update

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.defendant.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.defendant.prosecution_case_reference) })

  def show
    add_breadcrumb defendant.name,
                   defendant_path(defendant.arrest_summons_number || defendant.national_insurance_number)
  end

  def update
    if unlink
      flash[:notice] = I18n.t('defendant.unlink.success')
    else
      flash[:alert] = I18n.t('defendant.unlink.failure', error_messages: error_messages)
    end

    redirect_to defendant_path(defendant.arrest_summons_number)
  end

  def unlink
    defendant.update(unlink_attributes)
  rescue CourtDataAdaptor::Errors::BadRequest => e
    @errors = e.errors
    false
  rescue StandardError => e
    @errors = { unlink_reason: [e.message] }
    false
  end

  # TODO: adaptor needs to drop requirement for unlink_reason_text as superfluous
  # instead their should be an an unlink_other_reason_text or similar
  # for when users chooses the 'other' unlink reason code
  #
  def unlink_attributes
    raise I18n.t('defendant.unlink.errors.unlink_reason.attributes.code.inclusion') unless @unlink_reason

    other_reason = { unlink_other_reason_text: defendant_params[:unlink_other_reason_text] }
    attrs = { user_name: current_user.username, unlink_reason_code: @unlink_reason.code }

    if @unlink_reason.text_required?
      raise I18n.t('defendant.unlink.errors.unlink_reason.attributes.other_reason_text.presence') \
        if defendant_params[:unlink_other_reason_text].blank?
      attrs.merge!(other_reason)
    end

    attrs
  end

  def defendant_params
    params.permit(:id, :unlink_reason_code, :unlink_other_reason_text)
  end

  def error_messages
    @errors.map { |k, v| "#{k.to_s.humanize} #{v.join(', ')}" }.join("\n")
  end

  def defendant
    @defendant ||= @search.execute.first
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: defendant_params[:id])
    authorize! :create, @search
  end

  private

  def set_unlink_reasons
    @unlink_reasons = UnlinkReason.all
  end

  def set_unlink_reason
    @unlink_reason = UnlinkReason.find_by(code: defendant_params[:unlink_reason_code])
  end
end
