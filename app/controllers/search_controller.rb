class SearchController < ApplicationController
  protect_from_forgery with: :exception

  before_action :set_search_args

  def new
    @search = CommonPlatformSearch.new
  end

  def create
    @search = CommonPlatformSearch.new(query: @query, filter: @filter)
    @results = @search.call
    @message = "search executed for \"#{search_params[:query]}\" returned #{@results.size} results"
    redirect_to search_path, notice: @message
  end

  def index
  end

  private

  def set_search_args
    # search_params.select {|k, v| %w[query filter].include?(k) }
    @query = search_params[:query]
    @filter = search_params[:filter] || 'ref_number'
  end

  def search_params
    params.permit(:authenticity_token, :button, :query, :filter)
  end
end
