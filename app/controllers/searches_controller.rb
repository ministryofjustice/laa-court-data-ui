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
      @label = I18n.t('search.defendant_label')
      @hint = I18n.t('search.defendant_label_hint')
    else
      @label = I18n.t('search.case_number_label')
      @hint = I18n.t('search.case_number_label_hint')
    end
  end

  def search_params
    params.require(:search).permit(:query, :filter)
  end
end
