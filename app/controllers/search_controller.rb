class SearchController < ApplicationController
  before_action :set_search_args

  def new
    @search = CommonPlatformSearch.new
  end

  def create
    @search = CommonPlatformSearch.new(search_params)
  end

  private

  def set_search_args
    @query = search_params[:query]
    @filter = search_params[:filter] || 'ref_number'
  end

  def search_params
    params.permit(:query, :filter)
  end
end
