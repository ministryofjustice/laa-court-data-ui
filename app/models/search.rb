# frozen_string_literal: true

require_dependency 'court_data_adaptor'
require_dependency 'feature_flag'

class Search
  include ActiveModel::Model

  attr_accessor :filter, :term, :dob, :version2

  def self.filters
    [
      _filter(id: :case_reference,
              name: sanitize_html(I18n.t('search_filter.radio_case_reference_label'))),
      _filter(id: :defendant_reference,
              name: sanitize_html(I18n.t('search_filter.radio_defendant_reference_label_html'))),
      _filter(id: :defendant_name,
              name: sanitize_html(I18n.t('search_filter.radio_defendant_name_label_html')))
    ]
  end

  private_class_method def self._filter(args)
    SearchFilter.new(**args)
  end

  delegate :filters, to: :class

  def self.sanitize_html(html_string)
    ActionController::Base.helpers.sanitize(html_string, tags: ['b'])
  end

  validates :filter,
            presence: true,
            inclusion: { in: filters.map { |f| f.id.to_s },
                         message: I18n.t('generic.filter_not_recognized') }

  validates :term,
            presence: true,
            format: { with: /\A[A-Za-z0-9\s']+\z/ },
            char_length: { minimum: 2 }

  validates :dob,
            presence: true,
            if: proc { |search| search.filter.eql?('defendant_name') }

  def execute
    CdApi::SearchService.call(filter:, term:, dob:)
  end
end
