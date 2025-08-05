class HearingDaysController < ApplicationController
  before_action :load_and_authorize_application, :load_hearing_days, :load_hearing_details,
                :load_hearing_events

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  before_action :add_extra_breadcrumbs

  HEARING_SORT_DIRECTION = "asc".freeze

  def show; end

  private

  def load_and_authorize_application
    @application = Cda::CourtApplication.find(params[:court_application_id])
    authorize! :show, @application
  end

  def load_hearing_days
    load_hearing_day
    load_adjacent_hearing_days
  end

  def load_hearing_details
    details = load_hearing
    @hearing_details = helpers.decorate(details, Cda::HearingDecorator)
    @hearing_details.current_sitting_day = @hearing_day.sitting_day
    @hearing_details.skip_mapping_counsels_to_defendants = true
  rescue ActiveResource::ConnectionError => e
    logger.error e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  end

  def load_hearing
    Cda::Hearing.find(@hearing_day.hearing.id)
  rescue ActiveResource::ResourceNotFound
    # If the hearing has not been resulted, HMCTS will return a 404
    # We want to handle this gracefully
    Cda::Hearing.new
  end

  def load_hearing_events
    @hearing_events = Cda::HearingEventLog.find_from_hearing_and_date(params[:hearing_id],
                                                                      @hearing_day.date)
  rescue ActiveResource::ResourceNotFound
    logger.warn "No hearing events found for hearing #{params[:hearing_id]}"
  rescue ActiveResource::ConnectionError => e
    logger.error e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  end

  def load_hearing_day
    @hearing_day = flat_hearing_days.find do |hearing_day|
      hearing_day.hearing.id == params[:hearing_id] && hearing_day.date == params[:id].to_date
    end
  end

  def load_adjacent_hearing_days
    current_day_index = flat_hearing_days.index(@hearing_day)

    @next_day = flat_hearing_days[current_day_index + 1]
    @previous_day = flat_hearing_days[current_day_index - 1] if current_day_index.positive?
  end

  def flat_hearing_days
    @flat_hearing_days ||= @application.hearing_days_sorted_by(HEARING_SORT_DIRECTION)
  end

  def add_extra_breadcrumbs
    reference = @application.prosecution_case_reference
    add_breadcrumb prosecution_case_name(reference), prosecution_case_path(reference)
    add_breadcrumb t('subjects.appeal'), court_application_path(@application.application_id)
    add_breadcrumb t('hearing_days.show.breadcrumb', day: @hearing_day.day_string)
  end
end
