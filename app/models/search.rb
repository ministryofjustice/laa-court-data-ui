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
        description: I18n.t('search_filter.radio_case_reference_label_hint')
      ),
      SearchFilter.new(
        id: :defendant,
        name: I18n.t('search_filter.radio_defendant_label'),
        description: I18n.t('search_filter.radio_defendant_label_hint')
      )
    ]
  end

  # TODO: abstract (strategy pattern/dependency inversion)
  def execute
    case filter
    when 'case_reference'
      case_reference_search
    when 'defendant'
      defendant_search
    else
      raise CourtDataAdaptor::Resource::NotFound, ''
    end
  end

  private

  def case_reference_search
    CourtDataAdaptor::ProsecutionCase.where(prosecution_case_reference: query).all
  end

  def defendant_search
    results = query.split(' ').each_with_object([]) do |term, arr|
      arr.append(CourtDataAdaptor::ProsecutionCase.where(first_name: term, last_name: term).all)
    end
    results.flatten.uniq(&:id)
  end
end
