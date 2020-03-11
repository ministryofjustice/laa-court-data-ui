# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  before_action :load_and_authorize_search

  def show
    @results = @search.execute
    @prosecution_case = @results.first
  end

  private

  def load_and_authorize_search
    @search = Search.new(filter: 'case_reference', term: params[:id])
    authorize! :create, @search

    # @prosecution_case = CourtDataAdaptor::Resource::ProsecutionCase
    #   .where(prosecution_case_reference: params[:id])
    #   .includes(:defendants)
    #   .first
    # authorize! :show, @prosecution_case
  end
end
