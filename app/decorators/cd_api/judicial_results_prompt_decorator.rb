# frozen_string_literal: true

module CdApi
  class JudicialResultsPromptDecorator < BaseDecorator
    def formatted_entry
      value.to_s.gsub("\n", '<br/>')
    end
  end
end
