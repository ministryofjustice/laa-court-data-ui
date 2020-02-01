# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :set_search_args

  def new
    @search = Search.new
    authorize! :new, @search
  end

  def create
    @search = Search.new(query: @query, filter: @filter)
    authorize! :create, @search

    @results = @search.execute
    render 'new'
  end

  private

  def set_search_args
    @query = search_params[:query]
    @filter = search_params[:filter] || 'case_number'
    set_view_options
  end

  def set_view_options
    case @filter
    when 'defendant'
      @label = I18n.t('search.defendant_label')
      @hint = I18n.t('search.defendant_label_hint')
    else
      @label = I18n.t('search.case_reference_label')
      @hint = I18n.t('search.case_reference_label_hint')
    end
  end

  def search_params
    params.require(:search).permit(:query, :filter)
  end
end
