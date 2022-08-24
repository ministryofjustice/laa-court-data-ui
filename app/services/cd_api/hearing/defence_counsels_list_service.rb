# frozen_string_literal: true

module CdApi
  class Hearing::DefenceCounselsListService
    def self.call(defence_counsels)
      new(defence_counsels).call
    end

    def initialize(defence_counsels)
      @defence_counsels = defence_counsels
    end

    def call
      return [] if @defence_counsels.blank?

      defence_counsel_sentences
    end

    private

    def defence_counsel_sentences
      result = []
      @defence_counsels.each do |defence_counsel|
        sentence = "#{formatted_name(defence_counsel.attributes.symbolize_keys)} (#{formatted_status(defence_counsel.status)})"

        next (result << sentence) if defence_counsel.defendants.empty?

        defence_counsel.defendants.each do |defendant|
          next result << ("#{sentence} for #{I18n.t('generic.not_available').downcase}") unless (defendant && !defendant.is_a?(String))

          person_details = defendant.defendant_details&.person_details
          defendant_name = format_defendant_name(**person_details&.attributes&.symbolize_keys)

          result << ("#{sentence} for #{defendant_name}")
        end
      end
      result
    end

    def formatted_name(person_details)
      name(**person_details) || t('generic.not_available')
    end

    def name(first_name:, middle_name:, last_name:, **_opts)
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end

    def formatted_status(status)
      status || t('generic.not_available').downcase
    end

    def format_defendant_name(first_name:, middle_name:, last_name:, **_opts)
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end
  end
end
