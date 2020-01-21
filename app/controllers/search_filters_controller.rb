# frozen_string_literal: true

class SearchFiltersController < ApplicationController
  load_and_authorize_resource only: %i[new create]
  before_action :set_filter
  after_action :set_back_page_path, only: :new

  def new; end

  def create
    @search_filter = SearchFilter.new(id: params.fetch(:search_filter, nil)&.fetch(:id, nil))

    if @search_filter&.valid?
      redirect_to new_search_path(params: { search: { filter: @search_filter.id } })
    else
      render :new
    end
  end

  private

  def set_filter
    @search_filter = SearchFilter.new(id: params.fetch(:search_filter, nil)&.fetch(:id, nil))
  end

  def search_filter_params
    params.require(:search_filter).permit(:id)
  end
end
