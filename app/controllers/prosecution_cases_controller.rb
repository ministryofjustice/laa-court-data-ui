# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
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
    @prosecution_case = helpers.decorate(search_results.first)
    @prosecution_case.sort_order ||= sort_order
  end

  def search_results
    @search_results ||= @search.execute
  end

  def sort_order
    @sort_order ||= params[:sort_order]
  end
end
