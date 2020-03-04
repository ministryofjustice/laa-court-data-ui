# frozen_string_literal: true

require 'court_data_adaptor'

class Search
  include ActiveModel::Model

  attr_accessor :filter, :term, :dob

  validates :filter, presence: true
  validates :term, presence: true
  validates :dob,
            presence: true,
            if: proc { |search| search.filter.eql?('defendant_name') }

  def filters
    self.class.filters
  end

  def self.filters
    [
      SearchFilter.new(id: :case_reference,
                       name: I18n.t('search_filter.radio_case_reference_label'),
                       description: I18n.t('search_filter.radio_case_reference_label_hint')),
      SearchFilter.new(id: :defendant_reference,
                       name: I18n.t('search_filter.radio_defendant_reference_label'),
                       description: I18n.t('search_filter.radio_defendant_reference_label_hint')),
      SearchFilter.new(id: :defendant_name,
                       name: I18n.t('search_filter.radio_defendant_name_label'),
                       description: I18n.t('search_filter.radio_defendant_name_label_hint'))
    ]
  end

  def execute
    query.call
  end

  private

  def query
    send("#{filter}_query")
  end

  def case_reference_query
    CourtDataAdaptor::Query::ProsecutionCase.new(term)
  end

  def defendant_reference_query
    CourtDataAdaptor::Query::Defendant::ByReference.new(term)
  end

  def defendant_name_query
    CourtDataAdaptor::Query::Defendant::ByName.new(term, dob: dob)
  end
end
