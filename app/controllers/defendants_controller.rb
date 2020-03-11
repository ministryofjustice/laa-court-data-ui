# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :load_and_authorize_search

  def show
    @results = @search.execute
    @defendant = @results.first
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: params[:id])
    authorize! :create, @search
  end
end
