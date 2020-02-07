# frozen_string_literal: true

require 'court_data_adaptor'

class Search
  include ActiveModel::Model

  attr_accessor :adaptor
  attr_accessor :term

  def filters
    self.class.filters
  end

  def self.filters
    [
      SearchFilter.new(
        id: :case_reference,
        name: I18n.t('search_filter.radio_case_reference_label'),
        description: I18n.t('search_filter.radio_case_reference_label_hint')
      ),
      SearchFilter.new(
        id: :defendant,
        name: I18n.t('search_filter.radio_defendant_label'),
        description: I18n.t('search_filter.radio_defendant_label_hint')
      )
    ]
  end

  def execute
    adaptor.call
  end
end
