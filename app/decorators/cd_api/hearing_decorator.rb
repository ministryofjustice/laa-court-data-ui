# frozen_string_literal: true

module CdApi
  class HearingDecorator < BaseDecorator
    attr_accessor :current_sitting_day

    def cracked_ineffective_trial
      @cracked_ineffective_trial ||= decorate(object.hearing.cracked_ineffective_trial,
                                              CdApi::CrackedIneffectiveTrialDecorator)
    end

    def defence_counsels_list
      safe_join(defence_counsel_sentences, tag.br)
    end

    def prosecution_counsels_list
      formatted_prosecution_counsels = filter_prosecution_counsels.map { |pc| "#{pc.first_name&.capitalize} #{pc.last_name&.capitalize}" }

      return t('generic.not_available') if formatted_prosecution_counsels.blank?

      safe_join(formatted_prosecution_counsels, tag.br)
    end

    def defendants_list
      return [] if object.try(:hearing).nil? || hearing.prosecution_cases.blank?
      hearing.prosecution_cases.flat_map do |pc|
        decorate_all(pc.defendants, CdApi::DefendantsDecorator)
      end
    end

    private

    def defence_counsel_sentences
      return [t('generic.not_available')] if decorated_defence_counsels.empty?

      decorated_defence_counsels
    end

    def decorated_defence_counsels
      service = CdApi::HearingDetails::DefenceCounselsListService
      @decorated_defence_counsels ||= service.call(mapped_defence_counsels)
    end

    def mapped_defence_counsels
      @mapped_defence_counsels ||= map_defence_counsels
    end

    def filter_prosecution_counsels
      hearing.prosecution_counsels.select { |prosecution_counsel| attended_hearing_day?(prosecution_counsel) }
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

    def attended_hearing_day?(counsels)
      return false unless current_sitting_day

      counsels.attendance_days.include?(DateTime.parse(current_sitting_day).strftime('%Y-%m-%d'))
    end
  end
end
