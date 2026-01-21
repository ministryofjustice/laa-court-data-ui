class HearingDaysController < ApplicationController
  before_action :set_application

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  after_action :add_extra_breadcrumbs

  HEARING_SORT_DIRECTION = "asc".freeze

  def show
    authorize! :show, @application

    @hearing_day = current_hearing_day
    @previous_day, @next_day = get_adjacent_hearing_days(@hearing_day)
    details = load_hearing
    @hearing_details = helpers.decorate(details, Cda::HearingDecorator).tap do |decorated_hearing|
      decorated_hearing.current_sitting_day = @hearing_day.sitting_day
    end
    @hearing_events = Cda::HearingEventLog.find_from_hearing_and_date(params[:hearing_id], @hearing_day.date)
  rescue ActiveResource::ResourceNotFound
    logger.warn "No hearing events found for hearing #{params[:hearing_id]}"
  rescue ActiveResource::ConnectionError => e
    logger.error e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  end

  private

  def set_application
    @application = Cda::CourtApplication.find(params[:court_application_id])
  end

  def load_hearing
    Cda::Hearing.find(params[:hearing_id])
  rescue ActiveResource::ResourceNotFound
    # If the hearing has not been resulted, HMCTS will return a 404
    # We want to handle this gracefully
    Cda::Hearing.new
  end

  def current_hearing_day
    sorted_hearing_days.find do |hearing_day|
      hearing_day.hearing.id == params[:hearing_id] && hearing_day.date == params[:id].to_date
    end
  end

  def get_adjacent_hearing_days(hearing_day)
    current_day_index = sorted_hearing_days.find_index do |day|
      day.hearing.id == hearing_day.hearing.id && day.date == hearing_day.date
    end

    previous_day = sorted_hearing_days[current_day_index - 1] if current_day_index.positive?
    next_day = sorted_hearing_days[current_day_index + 1] if current_day_index < sorted_hearing_days.size - 1

    [previous_day, next_day]
  end

  def sorted_hearing_days
    @sorted_hearing_days ||= @application.hearing_days_sorted_by(HEARING_SORT_DIRECTION)
  end

  def add_extra_breadcrumbs
    reference = @application.application_reference
    add_breadcrumb prosecution_case_name(reference), prosecution_case_path(reference)
    add_breadcrumb t("subjects.#{@application.application_category}"),
                   court_application_path(@application.application_id)
    add_breadcrumb t('hearing_days.show.breadcrumb', day: @hearing_day.day_string)
  end
end
