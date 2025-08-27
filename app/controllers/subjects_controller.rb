class SubjectsController < ApplicationController
  before_action :load_and_authorize_application
  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  before_action :add_extra_breadcrumbs

  def show
    @form_model = @application.maat_linked? ? load_unlink_attempt : load_link_attempt

    return unless params.fetch(:include_offence_history, 'false') == 'true'

    @offence_history_collection = Cda::OffenceHistoryCollection.find_from_id_and_urn(
      @application.defendant.id,
      @application.prosecution_case_reference
    )
  end

  def link_form
    @form_model = load_link_attempt
  end

  def unlink_form
    @form_model = load_unlink_attempt
  end

  def link
    @form_model = load_link_attempt
    @form_model.validate!

    Cda::CourtApplicationLaaReference.create!(@form_model)
    redirect_to court_application_subject_path(@application.application_id),
                flash: { success: t('.success') }
  rescue ActiveResource::ConnectionError => e
    handle_link_failure(e.message, e)
    render :link_form
  rescue ActiveModel::ValidationError
    render :link_form
  end

  def unlink
    @form_model = load_unlink_attempt
    @form_model.validate!
    Cda::CourtApplicationLaaReference.update!(@form_model)
    redirect_to court_application_subject_path(@application.application_id),
                flash: { success: t('.success', maat_id: @form_model.maat_reference) }
  rescue ActiveResource::ConnectionError => e
    handle_unlink_failure(e.message, e)
    render :unlink_form
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    render :unlink_form
  end

  private

  def load_and_authorize_application
    @application = Cda::CourtApplication.find(params[:court_application_id])
    @subject = @application.subject_summary
    authorize! :show, @application
  end

  def add_extra_breadcrumbs
    reference = @application.prosecution_case_reference
    add_breadcrumb prosecution_case_name(reference), prosecution_case_path(reference)
    add_breadcrumb t("subjects.#{@application.application_category}"),
                   court_application_path(@application.application_id)
    add_breadcrumb @subject.name
  end

  def load_unlink_attempt
    UnlinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      reason_code: params.dig(:unlink_attempt, :reason_code).to_i,
      other_reason_text: params.dig(:unlink_attempt, :other_reason_text),
      maat_reference: @application.maat_reference
    )
  end

  def load_link_attempt
    LinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      maat_reference: params.dig(:link_attempt, :maat_reference)
    )
  end

  def handle_link_failure(message, exception = nil)
    logger.warn "LINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:maat_reference, cda_error_string(exception) || t('subjects.link.failure'))
  end

  def handle_unlink_failure(message, exception = nil)
    logger.warn "UNLINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:reason_code, cda_error_string(exception) || t('subjects.unlink.failure'))
  end

  def cda_error_string_context
    @application&.application_category
  end
end
