# frozen_string_literal: true

require_dependency 'court_data_adaptor'
require_dependency 'feature_flag'

class Search
  include ActiveModel::Model

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

  attr_accessor :filter, :term, :dob, :version2

  def filters
    self.class.filters
  end

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
    return query_cd_api if version2?
    Rails.logger.info 'V1_SEARCH_DEFENDANTS'
    query_cda.call
  end

  private

  def version2?
    version2
  end

  def query_cd_api
    CdApi::SearchService.call(filter:, term:, dob:)
  rescue ActiveResource::BadRequest
    Rails.logger.info 'CLIENT_ERROR_OCCURRED'
    empty_collection
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    Rails.logger.error 'SERVER_ERROR_OCCURRED'
    Sentry.capture_exception(e)
    empty_collection
  end

  def empty_collection
    []
  end

  def query_cda
    send("#{filter}_query")
  end

  def case_reference_query
    CourtDataAdaptor::Query::ProsecutionCase.new(term)
  end

  def defendant_reference_query
    CourtDataAdaptor::Query::Defendant::ByReference.new(term)
  end

  def defendant_name_query
    CourtDataAdaptor::Query::Defendant::ByName.new(term, dob:)
  end
end
