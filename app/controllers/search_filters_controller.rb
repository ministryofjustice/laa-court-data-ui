# frozen_string_literal: true

class SearchFiltersController < ApplicationController
  load_and_authorize_resource only: %i[new create]
  before_action :set_filter

  def new; end

  def create
    if @search_filter&.valid?
      redirect_to new_search_path(params: { search: { filter: @search_filter.id } })
    else
      render :new
    end
  end

  private

  def set_filter
    @search_filter = SearchFilter.new(id: params.dig(:search_filter, :id))
  end

  def search_filter_params
    params.permit(:search_filter).permit(:id)
  end
end
