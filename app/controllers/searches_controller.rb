# frozen_string_literal: true

class SearchesController < ApplicationController
  protect_from_forgery with: :exception

  before_action :set_search_args

  def new
    @search = Search.new
  end

  def create
    @search = Search.new(query: @query, filter: @filter)
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
      @label = 'Find a defendant'
      @hint = 'Search by MAAT number or defendant name'
    else
      @label = 'Find a case'
      @hint = 'Search by case number'
    end
  end

  def search_params
    params.require(:search).permit(:query, :filter)
  end
end
