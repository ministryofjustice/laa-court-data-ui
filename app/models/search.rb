# frozen_string_literal: true

require 'court_data_adaptor'

class Search
  include ActiveModel::Model

  attr_writer :filter
  attr_accessor :query

  def filter
    @filter || :case_reference
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
    case filter
    when 'case_reference'
      CourtDataAdaptor::ProsecutionCase.where(prosecution_case_reference: query).all
    else
      raise CourtDataAdaptor::Resource::NotFound, ''
    end
  end
end
