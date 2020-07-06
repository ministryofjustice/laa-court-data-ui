# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :set_defendant_asn_if_required,
                :load_and_authorize_search
  before_action :set_unlink_reasons,
                :set_link_attempt,
                :set_unlink_attempt,
                :set_defendant_if_required

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.defendant.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.defendant.prosecution_case_reference) })

  def edit
    add_breadcrumb defendant.name,
                   defendant_path(defendant.arrest_summons_number || defendant.national_insurance_number)
  end

  def create
    authorize! :create, :link_maat_reference, message: I18n.t('unauthorized.default')
    set_link_attempt
    if @link_attempt.valid?
      if link_laa_reference
        flash[:notice] = I18n.t('laa_reference.link.success')
      else
        flash[:alert] = I18n.t('laa_reference.link.failure', error_messages: error_messages)
      end
      redirect_to edit_defendant_path(@defendant.arrest_summons_number)
    else
      render 'edit'
    end
  end

  def update
    set_unlink_attempt
    if @unlink_attempt.valid?
      if unlink
        flash[:notice] = I18n.t('defendants.unlink.success')
      else
        flash[:alert] = I18n.t('defendants.unlink.failure', error_messages: error_messages)
      end

      redirect_to edit_defendant_path(@defendant.arrest_summons_number)
    else
      render 'edit'
    end
  end

  def unlink
    defendant.update(@unlink_attempt.to_unlink_attributes)
  rescue CourtDataAdaptor::Errors::BadRequest => e
    @errors = e.errors
    false
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

  def resource
    CourtDataAdaptor::Resource::LaaReference
  end

  def resource_params
    @resource_params ||= link_attempt_params.select! { |k, _v| k.in? %w[maat_reference defendant_id] }
  end

  def no_maat_id?
    params[:commit] == 'Create link without MAAT ID'
  end

  def defendant_params
    params.permit(:id, 
                  unlink_attempt: %i[reason_code other_reason_text], 
                  link_attempt: %i[id defendant_id maat_reference defendant_asn])
  end

  def unlink_attempt_params
    defendant_params[:unlink_attempt]
  end

  def link_attempt_params
    defendant_params[:link_attempt]
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

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: @defendant_asn)
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def set_defendant_asn_if_required
    defendant_asn
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

  def link_attempt_attributes
    return unless link_attempt_params

    link_attempt_params.merge(no_maat_id: no_maat_id?)
  end

  def set_link_attempt
    @link_attempt = if link_attempt_attributes
                      LinkAttempt.new(link_attempt_attributes)
                    else
                      LinkAttempt.new
                    end
  end

  def defendant_asn
    @defendant_asn ||= defendant_params[:id] || link_attempt_params[:defendant_asn] || link_attempt_params[:id]
  end
end
