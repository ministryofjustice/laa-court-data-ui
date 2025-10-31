module Cda
  class HearingDecorator < BaseDecorator
    attr_accessor :current_sitting_day

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

    def applicant_counsels_list
      return t('generic.not_available') unless loaded?
      return t('generic.not_available') if applicant_counsel_sentences.empty?

      safe_join(applicant_counsel_sentences, tag.br)
    end

    def prosecution_counsels_list
      formatted_counsels_list(hearing.prosecution_counsels)
    end

    def respondent_counsels_list
      return t('generic.not_available') unless loaded?

      formatted_counsels_list(hearing.respondent_counsels)
    end

    def formatted_counsels_list(counsels)
      return t('generic.not_available') unless loaded?

      formatted_counsels = filter_counsels(counsels).map { |pc| "#{pc.first_name&.capitalize} #{pc.last_name&.capitalize}" }

      return t('generic.not_available') if formatted_counsels.blank?

      safe_join(formatted_counsels, tag.br)
    end

    def judiciary_list
      return t('generic.not_available') if !loaded? || hearing.judiciary.none?

      safe_join(hearing.judiciary.map { |jd| "#{jd.title} #{jd.first_name} #{jd.last_name}" }, tag.br)
    end

    def hearing_days
      object.hearing.hearing_days || []
    end

    def earliest_sitting_day
      object.hearing.hearing_days.min_by(&:date)
    end

    private

    def defence_counsel_sentences
      @defence_counsel_sentences ||= Cda::HearingDetails::DefenceCounselsListService.call(
        mapped_defence_counsels
      ).presence || [t('generic.not_available')]
    end

    def applicant_counsel_sentences
      @applicant_counsel_sentences ||= Cda::HearingDetails::DefenceCounselsListService.call(
        filter_counsels(hearing.applicant_counsels), map_counsels_to_defendants: false
      ).presence || [t('generic.not_available')]
    end

    def mapped_defence_counsels
      @mapped_defence_counsels ||= map_defence_counsels
    end

    def filter_counsels(counsels)
      counsels.select { |counsel| attended_hearing_day?(counsel) }
    end

    def map_defence_counsels
      hearing.prosecution_cases.each do |pc|
        map_defence_counsels_defendants_to_case(pc)
      end
      filter_counsels(hearing.defence_counsels)
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

    def attended_hearing_day?(counsel)
      return false unless current_sitting_day

      counsel.attendance_days.include?(DateTime.parse(current_sitting_day).strftime('%Y-%m-%d'))
    end
  end
end
