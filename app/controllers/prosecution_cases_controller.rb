# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  include CourtDataAdaptorCachable

  before_action :load_and_authorize_search, :set_prosecution_case

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def show
    add_breadcrumb prosecution_case_name(@prosecution_case.prosecution_case_reference),
                   prosecution_case_path(@prosecution_case.prosecution_case_reference)
  end

  private

  def load_and_authorize_search
    @search = Search.new(filter: 'case_reference', term: params[:id])
    authorize! :create, @search
  end

  def set_prosecution_case
    @prosecution_case = helpers.decorate(prosecution_case_search_results.first)
  end

  # TODO: move to mixin?!
  def prosecution_case_search_results
    @search_results ||= cached_search_execute(@search)
  end
end
