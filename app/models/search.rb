# frozen_string_literal: true

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
        id: :case_number,
        name: I18n.t('search_filter.radio_case_number_label'),
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
    ['first result from CP', 'second result from CP']
  end
end
