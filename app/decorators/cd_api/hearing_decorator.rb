# frozen_string_literal: true

module CdApi
  class HearingDecorator < BaseDecorator
    def cracked_ineffective_trial
      @cracked_ineffective_trial ||= decorate(object.hearing.cracked_ineffective_trial,
                                              CdApi::CrackedIneffectiveTrialDecorator)
    end

    def defence_counsels_list
      # TODO: Add logic of attendance days for each defence
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
        # TODO: Confirm that defendant details is the same across cases and searching cases for a defence_counsel.defendant.id is accurate
        hearing.defence_counsels.each do |defence_counsel|
          defence_counsel.defendants.map! do |dc_defendant_id|
            next dc_defendant_id unless dc_defendant_id.is_a?(String)

            defendant_details = pc.defendants.find { |defendant| (dc_defendant_id == defendant.id) }
            defendant_details || dc_defendant_id
          end
        end
      end
      hearing.defence_counsels
    end
  end
end
