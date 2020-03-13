# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  before_action :load_and_authorize_search

  add_breadcrumb 'Search filters', :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def show
    @results = @search.execute
    @prosecution_case = @results.first
    add_breadcrumb 'Case details', prosecution_case_path(@prosecution_case.prosecution_case_reference)
  end

  private

  def load_and_authorize_search
    @search = Search.new(filter: 'case_reference', term: params[:id])
    authorize! :create, @search
  end
end
