# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :load_and_authorize_search

  add_breadcrumb 'Search filters', :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb 'Case details',
                 (proc { |v| v.prosecution_case_path(v.controller.defendant.prosecution_case_reference) })

  def show
    add_breadcrumb defendant.name,
                   defendant_path(defendant.arrest_summons_number || defendant.national_insurance_number)
  end

  def defendant
    @defendant ||= @search.execute.first
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: params[:id])
    authorize! :create, @search
  end
end
