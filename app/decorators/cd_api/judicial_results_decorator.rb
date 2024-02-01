# frozen_string_literal: true

module CdApi
  class JudicialResultsDecorator < BaseDecorator
    def formatted_date
      ordered_date&.to_datetime&.strftime('%d/%m/%Y')
    end

    def filtered_prompts
      return [] if prompts.blank?

      decorated_and_filtered_prompts
    end

    private

    def decorated_and_filtered_prompts
      @decorated_and_filtered_prompts ||= decorate_all(filter_prompts, CdApi::JudicialResultsPromptDecorator)
    end

    def filter_prompts
      prompts.select do |prompt|
        filter_by_allowed_prompts(prompt)
      end
    end

    def filter_by_allowed_prompts(prompt)
      allowed_judicial_results_prompts.select do |judicial_result|
        judicial_result['type_id'] == prompt.type_id
      end
    end

    def allowed_judicial_results_prompts
      Rails.application.config.x.allowed_judicial_results
    end
  end
end
