class SubjectsController < ApplicationController
  before_action :load_and_authorize_application, :load_link

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :application_search_breadcrumb_name, :search_breadcrumb_path

  def show; end

  def link
    return render :show unless @link_attempt.valid?

    if CourtDataAdaptor::Query::LinkCourtApplication.call(@link_attempt)
      redirect_to court_application_subject_path(@application.application_id),
                  flash: { notice: t('.success') }
    else
      @link_attempt.errors.add(:maat_reference, t('.failure'))
      render :show
    end
  rescue CourtDataAdaptor::Errors::BadRequest, CourtDataAdaptor::Errors::UnprocessableEntity => e
    handle_link_failure(e)
  end

  private

  def load_and_authorize_application
    @application = CourtDataAdaptor::Query::CourtApplication.new(params[:court_application_id]).call
    @subject = @application.subject_summary
    add_breadcrumb @subject.name
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end

  def load_link
    @link_attempt = LinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      maat_reference: params.dig(:link_attempt, :maat_reference)
    )
  end

  def handle_link_failure(exception)
    logger.warn "LINK FAILURE: #{exception.message}"
    @link_attempt.errors.add(:maat_reference, t('subjects.link.failure'))
    render :show
  end
end
