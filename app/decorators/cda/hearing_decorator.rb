module Cda
  class HearingDecorator < BaseDecorator
    attr_accessor :current_sitting_day, :skip_mapping_counsels_to_defendants

    def loaded?
      object.attributes.any?
    end

    def cracked_ineffective_trial
      @cracked_ineffective_trial ||= decorate(object.hearing.cracked_ineffective_trial,
                                              Cda::CrackedIneffectiveTrialDecorator)
    end

    def defence_counsels_list
      return t('generic.not_available') unless loaded?

      safe_join(defence_counsel_sentences, tag.br)
    end

    def prosecution_counsels_list
      return t('generic.not_available') unless loaded?

      formatted_prosecution_counsels = filter_prosecution_counsels.map { |pc| "#{pc.first_name&.capitalize} #{pc.last_name&.capitalize}" }

      return t('generic.not_available') if formatted_prosecution_counsels.blank?

      safe_join(formatted_prosecution_counsels, tag.br)
    end

    def judiciary_list
      return t('generic.not_available') if !loaded? || hearing.judiciary.none?

      safe_join(hearing.judiciary.map { |jd| "#{jd.title} #{jd.first_name} #{jd.last_name}" }, tag.br)
    end

    private

    def defence_counsel_sentences
      return [t('generic.not_available')] if decorated_defence_counsels.empty?

      decorated_defence_counsels
    end

    def decorated_defence_counsels
      service = Cda::HearingDetails::DefenceCounselsListService
      @decorated_defence_counsels ||= service.call(
        mapped_defence_counsels, map_counsels_to_defendants: !skip_mapping_counsels_to_defendants
      )
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
        defence_counsel.defendants&.map! do |dc_defendant_id|
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
