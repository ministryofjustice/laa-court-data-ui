# frozen_string_literal: true

module CdApi
  class JudicialResultsDecorator < BaseDecorator
    def formatted_date
      ordered_date&.to_datetime&.strftime('%d/%m/%Y')
    end

    def judicial_results_prompt_list
      decorate_all(prompts.flat_map.select { |prompt|
                     Rails.application.config.x.judicial_results.filter.to_a[0][1].any? do |filter|
                       filter.to_s.downcase.starts_with?(prompt.label.downcase)
                     end
                   }, CdApi::JudicialResultsPromptDecorator)
    end
  end
end

module CdApi
  class JudicialResultsPromptDecorator < BaseDecorator
    def formatted_entry
      value.to_s.gsub(/\n/, '<br/>').html_safe
    end
  end
end
