# frozen_string_literal: true

module CdApi
  class DefendantsDecorator < BaseDecorator
    def defendant_name
      [defendant_details.person_details.first_name, defendant_details.person_details.middle_name,
       defendant_details.person_details.last_name].compact.reject(&:empty?).join(' ')
    end

    def judicial_results_list
      decorate_all(offences.flat_map(&:judicial_results), CdApi::JudicialResultsDecorator)
    end
  end
end
