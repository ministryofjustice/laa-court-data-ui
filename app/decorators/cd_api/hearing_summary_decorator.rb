# frozen_string_literal: true

module CdApi
  class HearingSummaryDecorator < BaseDecorator
    attr_accessor :day

    def defence_counsel_list
      return t('generic.not_available') if defence_counsels.blank?

      safe_join(defence_counsel_sentences, tag.br)
    end

    def hearing_days
      @hearing_days ||= decorate_all(object.hearing_days, CdApi::HearingDayDecorator)
    end

    def formatted_estimated_duration
      return unless estimated_duration

      "#{t('hearing_summary.estimated_duration')} #{estimated_duration.downcase}"
    end

    private

    def defence_counsel_sentences
      decorated_defence_counsels&.map(&:name_status_and_defendants) || []
    end

    def decorated_defence_counsels
      decorate_all(mapped_defence_counsels, CdApi::DefenceCounselDecorator)
    end

    def mapped_defence_counsels
      defence_counsels.each do |defence_counsel|
        defence_counsel.defendants.map! do |defendant_id|
          details = defendants.find { |defendant| (defendant.id == defendant_id) }

          details || defendant_id
        end
      end
    end
  end
end
