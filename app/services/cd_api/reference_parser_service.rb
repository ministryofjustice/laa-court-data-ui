# frozen_string_literal: true

module CdApi
  class ReferenceParserService < CourtDataAdaptor::Query::Defendant::ReferenceParser
    def kind
      national_insurance_number? ? :nino : :asn
    end
  end
end
