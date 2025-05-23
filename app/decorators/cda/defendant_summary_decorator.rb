module Cda
  class DefendantSummaryDecorator < BaseDecorator
    def linked?
      maat_reference.present? && maat_reference.first != 'Z'
    end

    def maat_reference
      offence_summaries.filter_map { |os| os.laa_application.try(:reference) }.uniq.join(', ')
    end
  end
end
