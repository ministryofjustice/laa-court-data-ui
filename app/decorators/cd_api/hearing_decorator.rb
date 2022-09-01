# frozen_string_literal: true

module CdApi
  class HearingDecorator < BaseDecorator
    attr_accessor :current_sitting_day

    def cracked_ineffective_trial
      @cracked_ineffective_trial ||= decorate(object.hearing.cracked_ineffective_trial,
                                              CdApi::CrackedIneffectiveTrialDecorator)
    end

    def defence_counsels_list
      return t('generic.not_available') if hearing.defence_counsels.blank?

      safe_join(defence_counsel_sentences, tag.br)
    end

    private

    def defence_counsel_sentences
      decorated_defence_counsels || []
    end

    def decorated_defence_counsels
      CdApi::HearingDetails::DefenceCounselsListService.call(mapped_defence_counsels)
    end

    def mapped_defence_counsels
      @mapped_defence_counsels ||= map_defence_counsels
    end

    def map_defence_counsels
      hearing.prosecution_cases.each do |pc|
        map_defence_counsels_defendants_to_case(pc)
      end
      hearing.defence_counsels.select { |defence_counsel| attended_hearing_day?(defence_counsel) }
    end

    def map_defence_counsels_defendants_to_case(prosecution_case)
      hearing.defence_counsels.each do |defence_counsel|
        defence_counsel.defendants.map! do |dc_defendant_id|
          next dc_defendant_id unless dc_defendant_id.is_a?(String)

          defendant_details = prosecution_case.defendants.find do |defendant|
            (dc_defendant_id == defendant.id)
          end
          defendant_details || dc_defendant_id
        end
      end
    end

    def attended_hearing_day?(defence_counsel)
      return false unless current_sitting_day

      defence_counsel.attendance_days.include?(DateTime.parse(current_sitting_day).strftime('%Y-%m-%d'))
    end
  end
end
