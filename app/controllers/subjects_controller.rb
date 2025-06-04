class SubjectsController < ApplicationController
  # Note that as a breadcrumb is added in the `before_action`, the relative
  # positioning of the `add_breadcrumb` and `before_action` calls here
  # do matter, and changing them will affect the breadcrumb order in the UI.
  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :application_search_breadcrumb_name, :search_breadcrumb_path
  before_action :load_and_authorize_application, :load_link

  def show; end

  def link
    return render :show unless @form_model.valid?

    if CourtDataAdaptor::Query::LinkCourtApplication.call(@form_model)
      redirect_to court_application_subject_path(@application.application_id,
                                                 linked: @form_model.maat_reference),
                  flash: { notice: t('.success') }
    else
      handle_link_failure("Query failed without raising an exception")
    end
  rescue CourtDataAdaptor::Errors::BadRequest, CourtDataAdaptor::Errors::UnprocessableEntity => e
    handle_link_failure(e.message)
  end

  def unlink
    return render :show unless @form_model.valid?

    if CourtDataAdaptor::Query::UnlinkCourtApplication.call(@form_model)
      redirect_to court_application_subject_path(@application.application_id, unlinked: true),
                  flash: { notice: t('.success') }
    else
      handle_unlink_failure("Query failed without raising an exception")
    end
  rescue CourtDataAdaptor::Errors::BadRequest, CourtDataAdaptor::Errors::UnprocessableEntity => e
    handle_unlink_failure(e.message)
  end

  private

  def load_and_authorize_application
    @application = CourtDataAdaptor::Query::CourtApplication.new(params[:court_application_id]).call
    @subject = @application.subject_summary
    @link_status = CourtApplicationLinkStatus.new(@subject, params)
    add_breadcrumb @subject.name
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end

  def load_link
    @form_model = @link_status.maat_linked? ? load_unlink_attempt : load_link_attempt
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

  def handle_link_failure(message)
    logger.warn "LINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:maat_reference, t('subjects.link.failure'))
    render :show
  end

  def handle_unlink_failure(message)
    logger.warn "UNLINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:reason_code, t('subjects.unlink.failure'))
    render :show
  end
end
