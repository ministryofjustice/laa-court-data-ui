# frozen_string_literal: true

require 'court_data_adaptor'

class SearchesController < ApplicationController
  before_action :set_search_args

  def new
    @search = Search.new
    authorize! :new, @search
  end

  def create
    @search = Search.new(adaptor: adaptor)
    authorize! :create, @search

    @results = @search.execute
    render 'new'
  end

  private

  attr_reader :adaptor

  def set_search_args
    @term = search_params[:term]
    @filter = search_params[:filter] || 'case_reference'
    @adaptor = adaptor_for(@filter, @term)
    set_view_options
  end

  def adaptor_for(filter, term)
    case filter
    when 'defendant'
      CourtDataAdaptor::Query::Defendant.new(term)
    else
      CourtDataAdaptor::Query::ProsecutionCase.new(term)
    end
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
    params.require(:search).permit(:term, :filter)
  end
end
