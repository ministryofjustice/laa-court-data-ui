# frozen_string_literal: true

require 'court_data_adaptor'

class Search
  include ActiveModel::Model

  attr_accessor :filter, :term, :dob

  validates :filter, presence: { message: I18n.t('errors.models.search.filter.blank') }
  validates :term, presence: { message: I18n.t('errors.models.search.term.blank') }
  validates :dob,
            presence: { message: I18n.t('errors.models.search.dob.blank') },
            if: proc { |search| search.filter.eql?('defendant') }

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

  private

  def adaptor
    send("#{filter}_adaptor")
  end

  def defendant_adaptor
    CourtDataAdaptor::Query::Defendant.new(term, dob: dob)
  end

  def case_reference_adaptor
    CourtDataAdaptor::Query::ProsecutionCase.new(term)
  end
end
