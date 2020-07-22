# frozen_string_literal: true

module DefendantSearchable
  extend ActiveSupport::Concern

  def defendant
    @defendant ||= @search.execute.first
  end

  private

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_uuid', term: term)
    authorize! :create, @search
  end

  def set_defendant_if_required
    defendant
  end

  def term
    @defendant_uuid || defendant_params[:id]
  end
end
