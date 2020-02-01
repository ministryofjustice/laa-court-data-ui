# frozen_string_literal: true

require 'laa/court_data_adaptor'

class Search
  include ActiveModel::Model

  attr_writer :filter
  attr_accessor :query

  def filter
    @filter || :case_number
  end

  def filters
    self.class.filters
  end

  def self.filters
    [
      SearchFilter.new(
        id: :case_reference,
        name: I18n.t('search_filter.radio_case_reference_label'),
        description: nil
      ),
      SearchFilter.new(
        id: :defendant,
        name: I18n.t('search_filter.radio_defendant_label'),
        description: I18n.t('search_filter.radio_defendant_label_hint')
      )
    ]
  end

  def execute
    client.prosecution_case_query(query)
  end

  private

  def client
    @client ||= LAA::CourtDataAdaptor.client
  end
end
