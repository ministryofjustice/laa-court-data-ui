# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class Search
  include ActiveModel::Model

  # rubocop:disable Rails/OutputSafety
  def self.filters
    [
      _filter(id: :case_reference,
              name: I18n.t('search_filter.radio_case_reference_label')),
      _filter(id: :defendant_reference,
              name: I18n.t('search_filter.radio_defendant_reference_label_html').html_safe),
      _filter(id: :defendant_name,
              name: I18n.t('search_filter.radio_defendant_name_label_html').html_safe)
    ]
  end
  # rubocop:enable Rails/OutputSafety

  private_class_method def self._filter(args)
    SearchFilter.new(**args)
  end

  attr_accessor :filter, :term, :dob

  def filters
    self.class.filters
  end

  validates :filter, presence: true, inclusion: {
    in: filters.map { |f| f.id.to_s },
    message: 'Filter "%{value}" is not recognized'
  }

  validates :term, presence: true, visible_length: { minimum: 2 }
  validates :dob,
            presence: true,
            if: proc { |search| search.filter.eql?('defendant_name') }

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
