# frozen_string_literal: true

class SearchFilter
  include ActiveModel::Model

  validates :id, presence: { message: I18n.t('errors.models.search_filter.id.blank') }

  attr_accessor :id, :name, :description
end
