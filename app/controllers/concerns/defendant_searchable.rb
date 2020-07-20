# frozen_string_literal: true

module DefendantSearchable
  extend ActiveSupport::Concern

  def defendant
    @defendant ||= @search.execute.first
  end

  private

  def defendant_identifier
    defendant.id
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: term)
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def term
    laa_reference_params[:id] || defendant_params[:id]
  end
end
