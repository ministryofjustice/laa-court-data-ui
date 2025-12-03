class CourtApplicationsController < ApplicationController
  DEFAULT_SORT_DIRECTION = "asc".freeze

  before_action :load_and_authorize_application

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  add_breadcrumb proc { |v| v.prosecution_case_name(v.controller.application_reference) },
                 proc { |v| v.prosecution_case_path(v.controller.application_reference) }

  def show
    add_breadcrumb t("subjects.#{@application.application_category}")

    @date_sort_direction = params.fetch(:date_sort_direction, DEFAULT_SORT_DIRECTION)
  end

  def application_reference
    @application.application_reference
  end

  private

  def load_and_authorize_application
    @application = Cda::CourtApplication.find(params[:id])
    authorize! :show, @application
  end
end
