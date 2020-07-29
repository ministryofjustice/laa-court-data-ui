# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :authorize_defendant_search
  before_action :set_unlink_reasons,
                :set_unlink_attempt,
                :set_defendant_if_required

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  # add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.@defendant.asn) }),
  #                (proc { |v| v.prosecution_case_path(v.controller.defendant.id) })

  def edit
    add_breadcrumb defendant.name,
                   defendant_path(defendant.id)
  end

  # rubocop:disable Metrics/AbcSize
  def update
    if @unlink_attempt.valid?
      if unlink
        redirect_to new_laa_reference_path(id: defendant.id)
        flash[:notice] = I18n.t('defendants.unlink.success')
      else
        redirect_to edit_defendant_path(id: defendant.id)
        flash[:alert] = I18n.t('defendants.unlink.failure', error_messages: error_messages)
      end
    else
      render 'edit'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def unlink
    defendant.update(@unlink_attempt.to_unlink_attributes)
  rescue CourtDataAdaptor::Errors::BadRequest => e
    @errors = e.errors
    false
  end

  def defendant
    @defendant ||= @defendant_search.find(defendant_params[:id]).first
  end

  private

  def set_defendant_if_required
    defendant
  end

  def authorize_defendant_search
    @defendant_search = CourtDataAdaptor::Resource::Defendant
    authorize! :show, @defendant_search
  end

  def defendant_params
    params.permit(:id, unlink_attempt: %i[reason_code other_reason_text])
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
end
