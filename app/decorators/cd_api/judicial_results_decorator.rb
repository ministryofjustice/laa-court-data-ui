# frozen_string_literal: true

module CdApi
  class JudicialResultsDecorator < BaseDecorator
    def formatted_date
      ordered_date&.to_datetime&.strftime('%d/%m/%Y')
    end

    def judicial_results_prompt_list
      return [] if map_judicial_result_prompts.blank?
      decorate_all(map_judicial_result_prompts.select do |prompt|
                     filter_judicial_results_prompts(prompt)
                   end, CdApi::JudicialResultsPromptDecorator)
    end

    private

    def map_judicial_result_prompts
      prompts.flat_map
    end

    def filter_judicial_results_prompts(prompt)
      Rails.application.config.x.judicial_results.filter.to_a[0][1].any? do |filter|
        filter.to_s.downcase.starts_with?(prompt.label.downcase)
      end
    end
  end
end

module CdApi
  class JudicialResultsPromptDecorator < BaseDecorator
    def formatted_entry
      value.to_s.gsub(/\n/, '<br/>')
    end
  end
end
