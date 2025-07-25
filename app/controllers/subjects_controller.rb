class SubjectsController < ApplicationController
  before_action :load_and_authorize_application
  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  before_action :add_extra_breadcrumbs

  def show
    @form_model = @subject.maat_linked? ? load_unlink_attempt : load_link_attempt
  end

  def link
    @form_model = load_link_attempt
    @form_model.validate!

    if CourtDataAdaptor::Query::LinkCourtApplication.call(@form_model)
      redirect_to court_application_subject_path(@application.application_id),
                  flash: { notice: t('.success') }
    else
      handle_link_failure("Query failed without raising an exception")
    end
  rescue CourtDataAdaptor::Errors::Error => e
    handle_link_failure(e.message, e)
  rescue ActiveModel::ValidationError
    nil
  ensure
    render :show unless performed?
  end

  # rubocop:disable Metrics/MethodLength
  def unlink
    @form_model = load_unlink_attempt
    @form_model.validate!

    if CourtDataAdaptor::Query::UnlinkCourtApplication.call(@form_model)
      redirect_to court_application_subject_path(@application.application_id),
                  flash: { notice: t('.success') }
    else
      handle_unlink_failure("Query failed without raising an exception")
    end
  rescue CourtDataAdaptor::Errors::BadRequest,
         CourtDataAdaptor::Errors::UnprocessableEntity => e
    handle_unlink_failure(e.message, e)
  rescue StandardError => e
    logger.error "Error: SubjectsController#unlink: #{e.message}"
    Sentry.capture_exception(e)
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    nil
  ensure
    render :show unless performed?
  end
  # rubocop:enable Metrics/MethodLength

  private

  def load_and_authorize_application
    @application = CourtDataAdaptor::Query::CourtApplication.new(params[:court_application_id]).call
    @subject = @application.subject_summary
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end

  def add_extra_breadcrumbs
    reference = @application.case_summary.prosecution_case_reference
    add_breadcrumb prosecution_case_name(reference), prosecution_case_path(reference)
    add_breadcrumb t('subjects.appeal'), court_application_path(@application.application_id)
    add_breadcrumb @subject.name
  end

  def load_unlink_attempt
    UnlinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      reason_code: params.dig(:unlink_attempt, :reason_code).to_i,
      other_reason_text: params.dig(:unlink_attempt, :other_reason_text),
      maat_reference: @subject.maat_reference
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
end
