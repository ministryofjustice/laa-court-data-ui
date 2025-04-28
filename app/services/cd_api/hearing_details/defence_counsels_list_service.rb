# frozen_string_literal: true

module CdApi
  module HearingDetails
    class DefenceCounselsListService
      def self.call(defence_counsels, map_counsels_to_defendants: true)
        new(defence_counsels, map_counsels_to_defendants:).call
      end

      def initialize(defence_counsels, map_counsels_to_defendants:)
        @defence_counsels = defence_counsels
        @map_counsels_to_defendants = map_counsels_to_defendants
        @result = []
      end

      def call
        return [] if @defence_counsels.blank?

        build_defence_counsel_sentences
        @result
      end

      private

      def build_defence_counsel_sentences
        @defence_counsels.each do |defence_counsel|
          status = defence_counsel.status
          name_in_parts = defence_counsel.attributes.symbolize_keys
          sentence = "#{formatted_name(name_in_parts)} (#{formatted_status(status)})"

          next (@result << sentence) if defence_counsel.defendants.empty? || !@map_counsels_to_defendants
          build_defence_counsel_sentences_with_defendants(defence_counsel, sentence)
        end
      end

      def build_defence_counsel_sentences_with_defendants(defence_counsel, sentence)
        defence_counsel.defendants.each do |defendant|
          unless defendant && !defendant.is_a?(String)
            next @result << "#{sentence} for #{I18n.t('generic.not_available').downcase}"
          end

          person_details = defendant.defendant_details&.person_details
          defendant_name = name(**person_details&.attributes&.symbolize_keys)

          @result << "#{sentence} for #{defendant_name}"
        end
      end

      def formatted_name(person_details)
        name(**person_details) || I18n.t('generic.not_available')
      end

      def name(first_name:, middle_name:, last_name:, **)
        return nil unless first_name || middle_name || last_name

        [first_name, middle_name, last_name].filter_map { |n| n&.capitalize }.reject(&:empty?).join(' ')
      end

      def formatted_status(status)
        status || I18n.t('generic.not_available').downcase
      end
    end
  end
end
