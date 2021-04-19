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
    @search = Search.new(filter: 'case_reference', term: term)
    authorize! :create, @search
  end

  def set_prosecution_case
    @prosecution_case = helpers.decorate(search_results.first)
  end

  def search_results
    Rails.cache.fetch(term, expires_in: Rails.configuration.cache_expiry) do
      @search_results ||= @search.execute
    end
  end

  def term
    @term ||= params[:id]
  end
end
